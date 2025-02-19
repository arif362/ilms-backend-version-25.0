# frozen_string_literal: true

module PublicLibrary
  class Users < PublicLibrary::Base
    helpers PublicLibrary::QueryParams::UserParams
    resources :users do

      desc 'Verify auth token login user.'
      route_setting :authentication, optional: true
      get :verify_auth_token do
        error!('User not found', HTTP_CODE[:NOT_FOUND]) unless @current_user.present?
        status HTTP_CODE[:OK]
        present true
      end

      desc 'User Login'
      params do
        requires :phone, type: String
        requires :password, type: String
      end

      route_setting :authentication, optional: true
      post :login do
        @user = User.active.find_by(phone: params[:phone])
        error!('Invalid phone number or password', HTTP_CODE[:FORBIDDEN]) unless @user.present? && @user.is_active?
        error!('Invalid phone number or password.', HTTP_CODE[:FORBIDDEN]) unless @user.password == params[:password]

        status HTTP_CODE[:OK]
        AuthToken.generate_access_token(@user, @request_user_agent).merge!(library_id: @user.member&.library&.id || '',
                                                                           library_code: @user.member&.library&.code || '',
                                                                           library_name: @user.member&.library&.name || '',
                                                                           is_member: @user.member.present?,
                                                                           member_activated_at: @user.member&.activated_at)
      end

      desc 'User Logout'
      delete :logout do
        unless AuthToken.remove_access_token(@current_user, @request_user_agent)
          error!('Not Found', HTTP_CODE[:NOT_FOUND])
        end
        status HTTP_CODE[:OK]
      end

      desc 'Create User'
      params do
        use :user_create_params
      end

      route_setting :authentication, optional: true
      post do
        tmp_user = TmpUser.new(declared(params, include_missing: false))

        if tmp_user.save!
          tmp_user.otps.temporary_user.create_otp(tmp_user.phone)
          Lms::Entities::TmpUsers.represent(tmp_user)
        else
          error!('User failed to save', HTTP_CODE[:BAD_REQUEST])
        end
      end

      desc 'Set password'
      params do
        use :password_params
      end

      route_setting :authentication, optional: true
      post '/set_password' do
        tmp_user = TmpUser.find_by(id: params[:tmp_id])

        error!('User not found', HTTP_CODE[:NOT_FOUND]) if tmp_user.blank?
        error!('Invalid request, Please verify otp first', HTTP_CODE[:BAD_REQUEST]) unless tmp_user.is_otp_verified?

        otp = Otp.temporary_user.active.where(code: params[:otp], otp_able_id: params[:tmp_id])&.last


        error!('OTP verification required', HTTP_CODE[:NOT_FOUND]) unless otp.present?
        error!('OTP verification required', HTTP_CODE[:BAD_REQUEST]) unless otp.is_otp_verified?

        if User.active.find_by(tmp_id: params[:tmp_id]).present?
          error!('You have already set your password, plz login to continue',
                 HTTP_CODE[:BAD_REQUEST])
        end

        error!('Password cannot be blank', HTTP_CODE[:BAD_REQUEST]) if params[:password].blank?
        error!('Password didn\'t match', HTTP_CODE[:BAD_REQUEST]) if params[:password] != params[:password_confirmation]

        user = User.new(full_name: tmp_user.full_name,
                        gender: tmp_user.gender,
                        phone: tmp_user.phone,
                        email: tmp_user.email,
                        dob: tmp_user.dob,
                        password: params[:password],
                        password_confirmation: params[:password_confirmation],
                        is_active: true)
        otp.update!(is_used: true)
        tmp_user.destroy! if user.save!

        status 200
        PublicLibrary::Entities::Users.represent(user)
      end

      desc 'Reset password'
      params do
        use :reset_password_params
      end

      route_setting :authentication, optional: true
      post '/reset_password' do
        otp = Otp.active.reset_password.where(code: params[:otp], phone: params[:phone])&.last

        error!('OTP verification required', HTTP_CODE[:BAD_REQUEST]) unless otp.present?
        error!('OTP verification required', HTTP_CODE[:BAD_REQUEST]) unless otp.is_otp_verified?

        user = User.active.find_by(phone: otp.phone)

        error!('User not found', HTTP_CODE[:NOT_FOUND]) unless user.present?

        error!('Password cannot be blank', HTTP_CODE[:BAD_REQUEST]) if params[:password].blank?
        error!('Password didn\'t match', HTTP_CODE[:BAD_REQUEST]) if params[:password] != params[:password_confirmation]

        user.update!(password: params[:password], password_confirmation: params[:password_confirmation])
        otp.update!(is_used: true)

        status 200
        PublicLibrary::Entities::Users.represent(user)
      end

      desc 'Change phone number'
      params do
        use :change_phone_params
      end

      post '/change_phone' do
        error!('Members are unable to change their phone, please contact your library', HTTP_CODE[:FORBIDDEN]) if @current_user.member.is_active.present?

        unless @current_user.password == params[:current_password]
          error!('Invalid current password', HTTP_CODE[:BAD_REQUEST])
        end
        existing_user = User.find_by(phone: params[:phone])
        if existing_user.present? && existing_user != @current_user
          error!('Phone number already exist', HTTP_CODE[:BAD_REQUEST])
        end
        phone_change_request = @current_user.phone_change_requests.create(phone: params[:phone])
        otp = phone_change_request.otps.phone_change.create_otp(params[:phone])
        error!('Otp send failed', HTTP_CODE[:BAD_REQUEST]) unless otp.present?
        status HTTP_CODE[:OK]
      end

      desc 'User Details'
      get '/profile' do
        PublicLibrary::Entities::Users.represent(@current_user)
      end

      desc 'User current circulation fine'
      params do
        use :pagination, per_page: 25
      end
      get '/fine/circulations' do
        borrowed = CirculationStatus.get_status(:borrowed)
        current_circulations = @current_user.member&.circulations&.where('circulation_status_id = ? AND return_at < ?', borrowed.id, Date.today.end_of_day)
        PublicLibrary::Entities::CurrentCirculationFine.represent(paginate(current_circulations.order(id: :desc)))
      end

      desc 'User current fine of unpaid invoices'
      params do
        use :pagination, per_page: 25
      end
      get '/unpaid_invoices' do
        unpaid_invoices = @current_user.invoices.fine.where.not(invoice_status: :paid)
        PublicLibrary::Entities::UnpaidInvoices.represent(paginate(unpaid_invoices.order(id: :desc)))
      end

      desc 'User Update'
      params do
        use :user_update_params
      end
      put '/profile_update' do
        user = @current_user
        error!('User not found', HTTP_CODE[:NOT_FOUND]) unless user.present?
        member = user.member
        if member&.present?
          library_name = @locale == :en ? member.library&.name : member.library&.bn_name
          error!("Please contact the head of library of #{library_name} to change profile information",
                 HTTP_CODE[:NOT_ACCEPTABLE])
        end
        user.update!(declared(params, include_missing: false).merge!(updated_by: @current_user))
        PublicLibrary::Entities::UserProfile.represent(user)
      end

      desc 'Change password'
      params do
        use :change_password_params
      end

      put '/change_password' do
        error!('User not found', HTTP_CODE[:NOT_FOUND]) if @current_user.blank?

        unless @current_user.password == params[:current_password]
          error!('Invalid current password', HTTP_CODE[:BAD_REQUEST])
        end

        error!('Password cannot be blank', HTTP_CODE[:BAD_REQUEST]) if params[:password].blank?
        error!('Password didn\'t match', HTTP_CODE[:BAD_REQUEST]) if params[:password] != params[:password_confirmation]
        if @current_user.password == params[:password]
          error!('New password can\'t be same as old one', HTTP_CODE[:BAD_REQUEST])
        end

        @current_user.update!(password: params[:password],
                              password_confirmation: params[:password_confirmation], updated_by: @current_user)

        PublicLibrary::Entities::Users.represent(@current_user)
      end

      desc 'User Photo Update'
      params do
        use :user_photo_update_params
      end
      put '/profile_image_update' do
        user = @current_user
        error!('User not found', HTTP_CODE[:NOT_FOUND]) unless user.present?
        user.update!(declared(params, include_missing: false).merge!(updated_by: @current_staff))
        PublicLibrary::Entities::UserProfile.represent(user)
      end

      desc 'Delete user account'
      params do
        requires :password, type: String
      end

      post :delete_account do
        error!('Incorrect password', HTTP_CODE[:NOT_ACCEPTABLE]) unless @current_user.password == params[:password]
        member = @current_user&.member
        if member.blank?
          @current_user.update!(is_active: false, is_deleted: true, deleted_at: DateTime.current, updated_by: @current_user)
          PublicLibrary::Entities::Users.represent(@current_user)
        else
          if @current_user.account_deletion_requests.pending.present?
            error!('You have pending deletion request', HTTP_CODE[:NOT_ACCEPTABLE])
          end
          validate_params = AccountDeletionManagement::ValidateAccountDeletion.call(user: @current_user)
          error!(validate_params.error.to_s, HTTP_CODE[:NOT_ACCEPTABLE]) unless validate_params.success?
          deletion_request = @current_user.account_deletion_requests.new
          PublicLibrary::Entities::AccountDeletionRequest.represent(deletion_request) if deletion_request.save!
        end
      end
    end
  end
end
