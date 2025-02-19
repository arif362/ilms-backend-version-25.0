# frozen_string_literal: true

module Lms
  class PhoneChangeRequests < Lms::Base
    helpers Lms::QueryParams::PhoneChangeRequestParams

    resources :phone_change_requests do
      desc 'resend otp for security money withdraw request'
      params do
        use :change_phone_resend_otp_params
      end

      post 'resend_otp' do
        staff = @current_library.staffs.find_by(id: params[:staff_id])
        unless staff.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff not valid for this library' },
                                  @current_library, false)
          error!('Staff not valid for this library', HTTP_CODE[:NOT_FOUND])
        end
        member = Member.find_by(id: params[:member_id])
        unless member.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Member not found' },
                                  staff,
                                  false)
          error!('Member not found', HTTP_CODE[:NOT_FOUND])
        end
        user = member.user
        existing_user = User.find_by(phone: params[:phone])
        if existing_user.present? && existing_user != user
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:BAD_REQUEST], error: 'Phone number already exist' },
                                  staff,
                                  false)
          error!('Phone number already exist', HTTP_CODE[:BAD_REQUEST])
        end
        otp = user.otps.phone_change.create_otp(params[:phone])
        unless otp.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:BAD_REQUEST], error: 'Otp send failed' },
                                  staff,
                                  false)
          error!('Otp send failed', HTTP_CODE[:BAD_REQUEST])
        end
        LmsLogJob.perform_later(request.headers.merge(params:),
                                { status_code: HTTP_CODE[:CREATED] },
                                staff, true)
        status HTTP_CODE[:CREATED]
      end

      desc 'Change phone number'
      params do
        use :change_phone_params
      end

      post do
        staff = @current_library.staffs.library.find_by(id: params[:staff_id])
        unless staff.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                  @current_library, false)
          error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
        end
        member = Member.find_by(id: params[:member_id])
        unless member.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:FORBIDDEN], error: 'Member not found' },
                                  staff,
                                  false)
          error!('Member not found', HTTP_CODE[:FORBIDDEN])
        end
        if member.library != @current_library
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:BAD_REQUEST],
                                    error: 'Not a member of current library' },
                                  staff, false)
          error!('Not a member of current library', HTTP_CODE[:BAD_REQUEST])
        end
        user = member.user
        otp = user.otps.phone_change.active.where(code: params[:otp])&.last
        unless otp.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_ACCEPTABLE],
                                    error: 'Otp not matched. Please resend otp again' },
                                  staff, false)
          error!('Otp not matched. Please resend otp again', HTTP_CODE[:NOT_ACCEPTABLE])
        end
        if otp.expired?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Expired OTP' },
                                  staff, false)
          error!('Expired OTP', HTTP_CODE[:NOT_ACCEPTABLE])
        end
        otp.update!(is_otp_verified: true)
        LmsLogJob.perform_later(request.headers.merge(params:),
                                { status_code: HTTP_CODE[:OK] },
                                staff, true)
        existing_user = User.find_by(phone: params[:phone])
        if existing_user.present? && existing_user != user
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:BAD_REQUEST], error: 'Phone number already exist' },
                                  staff,
                                  false)
          error!('Phone number already exist', HTTP_CODE[:BAD_REQUEST])
        end
        phone_change_request = user.phone_change_requests.create!(phone: otp.phone)
        user.update!(phone: phone_change_request.phone)
        LmsLogJob.perform_later(request.headers.merge(params:),
                                { status_code: HTTP_CODE[:OK] },
                                staff, true)
        Lms::Entities::UserList.represent(user)
      end
    end
  end
end
