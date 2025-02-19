# frozen_string_literal: true

module Lms
  class Patrons < Lms::Base
    helpers Lms::QueryParams::PatronParams
    resources :patrons do

      desc 'Create registered user with membership request details with accepted status'
      params do
        use :patron_create_params
      end

      post do
        params_except_images = params.except(:profile_image_file, :nid_front_image_file, :nid_back_image_file,
                                              :birth_certificate_image_file, :student_id_image_file, :verification_certificate_image_file)

        staff = @current_library.staffs.library.find_by(id: params[:staff_id])
        if staff.nil?
          LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff not found' },
                                  @current_library, false)
          error!('Staff not found', HTTP_CODE[:NOT_FOUND])
        end

        member = Member.find_by(identity_number: params[:identity_number])
        if member.present?
          LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                  { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: "Member already exist by identity_number: #{params[:identity_number]}" },
                                  staff, false)
          error!("Member already exist by identity_number: #{params[:identity_number]}", HTTP_CODE[:NOT_ACCEPTABLE])
        end


        patron = User.active.find_by(phone: params[:phone])
        patron ||= TmpUser.where(phone: params[:phone]).last

        unless patron.present?
          LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                  { status_code: HTTP_CODE[:BAD_REQUEST], error: 'OTP not verified' },
                                  staff, false)
          error!('OTP not verified', HTTP_CODE[:BAD_REQUEST])
        end
        unless patron.otps&.last&.is_otp_verified
          LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                  { status_code: HTTP_CODE[:BAD_REQUEST], error: 'OTP not verified' },
                                  staff, false)
          error!('OTP not verified', HTTP_CODE[:BAD_REQUEST])
        end

        if params[:card_delivery_type] == 'home_delivery'
          if params[:delivery_division_id].blank?
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Delivery division required' },
                                    staff, false)
            error!('Delivery division required', HTTP_CODE[:NOT_ACCEPTABLE])
          end
          if params[:delivery_district_id].blank?
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Delivery district required' },
                                    staff, false)
            error!('Delivery district required', HTTP_CODE[:NOT_ACCEPTABLE])
          end
          if params[:delivery_thana_id].blank?
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Delivery thana required' },
                                    staff, false)
            error!('Delivery thana required', HTTP_CODE[:NOT_ACCEPTABLE])
          end
        end

        basic_params = declared(params, include_missing: false)
        membership_request_params = { request_detail_attributes: basic_params.except(:staff_id, :password,
                                                                                      :password_confirmation).merge!(library_id: @current_library.id) }

        user = User.find_by(phone: basic_params[:phone])

        ActiveRecord::Base.transaction do
          unless user.present?
            user = User.new
            user.phone = basic_params[:phone]
            user.gender = basic_params[:gender]
            user.full_name = basic_params[:full_name]
            user.password = basic_params[:password]
            user.password_confirmation = basic_params[:password_confirmation]
            user.email = basic_params[:email]
            user.dob = basic_params[:dob]
            user.is_active = true
            if user.save!
              LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                      { status_code: HTTP_CODE[:OK] },
                                      staff, true)
            end
          end

          validate_params = MembershipManagement::ManageMembershipRequest.call(user:,
                                                                               request_params: membership_request_params[:request_detail_attributes],
                                                                               request_type: 'initial')
          unless validate_params.success?
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: validate_params.error.to_s },
                                    staff, false)
            error!(validate_params.error.to_s, HTTP_CODE[:NOT_ACCEPTABLE])
          end
          membership = user.membership_requests.payment_pending.build(membership_request_params.merge!(created_by_id: staff.id,
                                                                                                       request_type: 'initial'))
          raise ActiveRecord::Rollback unless membership.save!

          %w[present permanent].each do |type|
            SavedAddress.add_address(user, type.titleize.to_s, params["#{type}_address".to_sym],
                                     params["#{type}_division_id".to_sym], params["#{type}_district_id".to_sym],
                                     params["#{type}_thana_id".to_sym], user.full_name, user.phone, params["#{type}_delivery_area_id".to_sym], params["#{type}_delivery_area".to_sym], type.to_s.to_sym)
          end

          patron.destroy if patron.otps.last.otp_able.is_a?(TmpUser)
        end
        membership = user.membership_requests&.last
        if membership.present?
          user.image.attach(membership.request_detail.profile_image.blob)
          user.save!
        end
        Lms::Entities::Patrons.represent(user)
      end


      desc 'Check user exist or not and send otp'
      params do
        requires :phone, type: String, regexp: /(\A(\+88|0088)?(01)[3456789](\d){8})\z/
        requires :identity_type, type: String, values: Member.identity_types.keys
        requires :identity_number, type: String
        requires :staff_id, type: Integer, allow_blank: false
      end

      get '/check' do
        staff = @current_library.staffs.library.find_by(id: params[:staff_id])
        if staff.nil?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff not found' },
                                  @current_library, false)
          error!('Staff not found', HTTP_CODE[:NOT_FOUND])
        end

        member = Member.send(params[:identity_type].to_sym).find_by(identity_number: params[:identity_number])
        user = member.present? ? member.user : User.find_by(phone: params[:phone])

        if user.blank?
          tmp_user = TmpUser.new(phone: params[:phone])
          if tmp_user.save!
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:OK] },
                                    staff, true)
            tmp_user.otps.temporary_user.create_otp(tmp_user.phone)
          end

          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Patron not found' },
                                  staff, false)
          error!('Patron not found', HTTP_CODE[:NOT_FOUND])
        elsif user.member.blank?
          user.otps.registered_user.create_otp(user.phone) unless user.member.present?
        end

        Lms::Entities::Patrons.represent(user)
      end

      desc 'Smart member info by self-check machine'
      params do
        optional :phone, type: String
        optional :smart_card_number, type: String
        optional :email, type: String
      end

      get '/member_info' do
        if params[:smart_card_number].present?
          user = LibraryCard.active.where(smart_card_number: params[:smart_card_number])&.last&.member&.user
        elsif params[:phone].present?
          user = User.find_by(phone: params[:phone])
        elsif params[:email].present?
          user = User.find_by(email: params[:email])
        else
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:BAD_REQUEST], error: 'Please provide smart-card-number/phone/email' },
                                  @current_library, false)
          error!('Please provide smart-card-number/phone/email', HTTP_CODE[:BAD_REQUEST])
        end

        if user&.member.nil?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Member not found' },
                                  @current_library, false)
          error!('Member not found', HTTP_CODE[:NOT_FOUND])
        end

        Lms::Entities::MemberInfo.represent(user)
      end

      desc 'Return Patron pending Fine'
      params do
        optional :phone, type: String
        optional :smart_card_number, type: String
        optional :email, type: String
        optional :staff_id, type: Integer, allow_blank: false
        optional :is_machine, type: Boolean, values: [true, false], allow_blank: false
      end
      get '/fines/pending' do
        if params[:email].blank? && params[:phone].blank? && params[:smart_card_number].blank?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CUSTOM_CODE[:NOT_ELIGIBLE], error: 'Need to provide email or phone or smart_card_number' },
                                  @current_library, false)
          error!('Need to provide email or phone or smart_card_number', HTTP_CUSTOM_CODE[:NOT_ELIGIBLE], [])
        end

        unless params[:is_machine].present?
          if params[:staff_id].blank?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CUSTOM_CODE[:STAFF_ID_REQUIRED], error: 'Staff id required' },
                                    @current_library, false)
            error!('Staff id required', HTTP_CUSTOM_CODE[:STAFF_ID_REQUIRED], [])
          end
          staff = @current_library.staffs.find_by(id: params[:staff_id])
          unless staff.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CUSTOM_CODE[:STAFF_NOT_FOUND], error: 'Staff not found' },
                                    @current_library, false)
            error!('Staff not found', HTTP_CUSTOM_CODE[:STAFF_NOT_FOUND], [])
          end
        end

        if params[:smart_card_number].present?
          user = LibraryCard.find_by(smart_card_number: params[:smart_card_number])&.member&.user
        elsif params[:phone].present?
          user = User.find_by(phone: params[:phone])
        elsif params[:email].present?
          user = User.find_by(email: params[:email])
        end

        if user.nil?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Member not found' },
                                  @current_library, false)
          error!('User not found', HTTP_CODE[:NOT_FOUND])
        end

        if user&.member.nil?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Member not found' },
                                  @current_library, false)
          error!('Member not found', HTTP_CODE[:NOT_FOUND])
        end
        pending_fine = user&.invoices&.fine&.pending
        Lms::Entities::PatronFines.represent(pending_fine)
      end

      desc 'patron present address update'
      params do
        use :patron_present_address_update_params
      end
      put '/present_address/update' do
        staff = @current_library.staffs.library.find_by(id: params[:staff_id])
        if staff.nil?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff not found' },
                                  @current_library, false)
          error!('Staff not found', HTTP_CODE[:NOT_FOUND])
        end

        member = Member.find(params[:member_id])
        if member.nil?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Member not found' },
                                  @current_library, false)
          error!('Member not found', HTTP_CODE[:NOT_FOUND])
        end

        address = member.user.saved_addresses.present.first
        if address.nil?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Address not found' },
                                  @current_library, false)
          error!('Address not found', HTTP_CODE[:NOT_FOUND])
        end

        address.updated_by = staff
        if address.update!(declared(params, include_missing: false).except(:staff_id, :member_id))
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:OK] },
                                  staff, true)
        end
        Lms::Entities::SavedAddress.represent(address)
      end

      route_param :id do
        desc 'Return Patron Details'
        get do
          member = @current_library.members.find_by(id: params[:id])
          user = member.present? ? member.user : User.find_by(id: params[:id])

          if user.nil?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Patron Not Found' },
                                    @current_library, false)
            error!('Patron Not Found', HTTP_CODE[:NOT_FOUND])
          end

          Lms::Entities::Patrons.represent(user, request_source: "lms")
        end
      end

    end
  end
end
