# frozen_string_literal: true

module Lms
  class Users < Lms::Base
    helpers Lms::QueryParams::UserParams
    resources :users do

      desc 'User Validate'
      params do
        use :validate_params
      end
      get :validate do
        if params[:is_member] == false
          user = User.active.find_by(phone: params[:phone])
          unless user.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:FORBIDDEN], error: 'User not found' },
                                    @current_library, false)
            error!('User not found', HTTP_CODE[:FORBIDDEN])
          end

          unless params[:phone].present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:FORBIDDEN], error: 'phone is required' },
                                    @current_library, false)
            error!('phone is required', HTTP_CODE[:FORBIDDEN])
          end
          unless params[:password].present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:FORBIDDEN], error: 'password is required' },
                                    @current_library, false)
            error!('password is required', HTTP_CODE[:FORBIDDEN])
          end
          unless user.present? && user.is_active?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:FORBIDDEN], error: 'Invalid phone number or password' },
                                    @current_library, false)
            error!('Invalid phone number or password', HTTP_CODE[:FORBIDDEN])
          end

          unless user.password == params[:password]
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:FORBIDDEN], error: 'Invalid phone number or password' },
                                    @current_library, false)
            error!('Invalid phone number or password.', HTTP_CODE[:FORBIDDEN])
          end
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:OK] },
                                  @current_library, true)
          Lms::Entities::Users.represent(user)
        else
          unless params[:library_card_number].present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:FORBIDDEN], error: 'library Card Number is required' },
                                    @current_library, false)
            error!('library Card Number is required', HTTP_CODE[:FORBIDDEN])
          end
          library_card = LibraryCard.active.find_by(smart_card_number: params[:library_card_number])
          if library_card.nil?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'library Card is not found' },
                                    @current_library, false)
            error!('library Card is not found', HTTP_CODE[:NOT_FOUND])
          end
          member = library_card.member
          unless member.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Member not found' },
                                    @current_library, false)
            error!('Member not found', HTTP_CODE[:NOT_FOUND])
          end
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:OK] },
                                  @current_library, true)
          Lms::Entities::Members.represent(member.user)
        end
      end

      desc 'Register User'
      params do
        use :user_register_params
      end

      post :register do
        tmp_user = TmpUser.new(declared(params, include_missing: false))

        if tmp_user.save!
          tmp_user.otps.temporary_user.create_otp(tmp_user.phone)
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:CREATED] },
                                  @current_library, true)
          Lms::Entities::TmpUsers.represent(tmp_user)
        else
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:BAD_REQUEST], error: 'User failed to save' },
                                  @current_library, false)
          error!('User failed to save', HTTP_CODE[:BAD_REQUEST])
        end
      end

      desc 'Reset Password Otp Send'
      params do
        requires :phone, type: String, allow_blank: false
      end

      post '/resend_otp' do
        user = TmpUser.find_by(phone: params[:phone])
        unless user.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'User not found' },
                                  @current_library, false)
          error!('User not found', HTTP_CODE[:NOT_FOUND])
        end

        if user.otps.temporary_user.create_otp(user.phone)
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:OK] },
                                  @current_library, true)
          status HTTP_CODE[:OK]
        else
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:UNPROCESSABLE_ENTITY] },
                                  @current_library, false)
        end
      end

      desc 'Verify OTP.'
      params do
        use :otp_verify_params
      end

      post '/verify_otp' do
        otp = Otp.temporary_user.active.where(code: params[:otp])&.last
        unless otp.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Otp not matched; Please resend otp again' },
                                  @current_library, false)
          error!('Otp not matched; Please resend otp again', HTTP_CODE[:NOT_FOUND])
        end

        if otp.expired?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:UNPROCESSABLE_ENTITY], error: 'Expired OTP' },
                                  @current_library, false)
          error!('Expired OTP', HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
        unless otp.otp_able.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'User not found' },
                                  @current_library, false)
          error!('User not found', HTTP_CODE[:NOT_FOUND])
        end

        response = { otp: otp.code, expired_at: otp.expiry }

        if otp.otp_able_type == 'TmpUser'
          otp.otp_able.update!(is_otp_verified: true)
          response = response.merge(tmp_id: otp.otp_able_id)
        end

        otp.update!(is_otp_verified: true, is_used: true)
        LmsLogJob.perform_later(request.headers.merge(params:),
                                { status_code: HTTP_CODE[:OK] },
                                @current_library, true)
        status HTTP_CODE[:OK]
        response
      end

      desc 'Set password'
      params do
        use :password_params
      end

      post '/set_password' do
        tmp_user = TmpUser.find_by(id: params[:tmp_id])

        if tmp_user.blank?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'User not found' },
                                  @current_library, false)
          error!('User not found', HTTP_CODE[:NOT_FOUND])
        end
        unless tmp_user.is_otp_verified?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:BAD_REQUEST], error: 'Invalid request, Please verify otp first' },
                                  @current_library, false)
          error!('Invalid request, Please verify otp first', HTTP_CODE[:BAD_REQUEST])
        end

        if User.active.find_by(tmp_id: params[:tmp_id]).present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:BAD_REQUEST],
                                    error: 'You have already set your password, plz login to continue' },
                                  @current_library, false)
          error!('You have already set your password, plz login to continue', HTTP_CODE[:BAD_REQUEST])
        end

        if params[:password].blank?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:BAD_REQUEST], error: 'Password cannot be blank' },
                                  @current_library, false)
          error!('Password cannot be blank', HTTP_CODE[:BAD_REQUEST])
        end

        user = User.new(full_name: tmp_user.full_name,
                        phone: tmp_user.phone,
                        email: tmp_user.email,
                        dob: tmp_user.dob,
                        password: params[:password],
                        password_confirmation: params[:password],
                        is_active: true)
        tmp_user.destroy! if user.save!

        status 200
        LmsLogJob.perform_later(request.headers.merge(params:),
                                { status_code: HTTP_CODE[:OK] },
                                @current_library, true)
        Lms::Entities::Users.represent(user)
      end
    end
  end
end
