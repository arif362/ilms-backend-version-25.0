module Lms
  class Otps < Lms::Base

    resources :otps do
      desc 'Send an otp.'
      params do
        requires :phone, type: String, allow_blank: false
        requires :staff_id, type: Integer, allow_blank: false
      end

      post '/resend' do
        staff = @current_library.staffs.library.find_by(id: params[:staff_id])
        if staff.nil?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff not found' },
                                  @current_library, false)
          error!('Staff not found', HTTP_CODE[:NOT_FOUND])
        end

        user = User.active.find_by(phone: params[:phone])
        user ||= TmpUser.find_by(phone: params[:phone])
        unless user.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'User not found' },
                                  staff, false)
          error!('User not found', HTTP_CODE[:NOT_FOUND])
        end

        user.otps.create_otp(user.phone)
        # send_otp method will apply when sms gateway available from client

        status HTTP_CODE[:OK]
      end

      desc 'Verify OTP.'
      params do
        requires :otp, type: String, allow_blank: false
        requires :otp_type, type: String, allow_blank: false, values: Otp.otp_types.keys
        requires :staff_id, type: Integer, allow_blank: false
      end

      post '/verify' do
        staff = @current_library.staffs.library.find_by(id: params[:staff_id])
        if staff.nil?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff not found' },
                                  @current_library, false)
          error!('Staff not found', HTTP_CODE[:NOT_FOUND])
        end

        otp = Otp.send(params[:otp_type].to_sym).active.where(code: params[:otp])&.last
        unless otp.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Otp not matched; Please resend otp again' },
                                  staff, false)
          error!('Otp not matched; Please resend otp again', HTTP_CODE[:NOT_FOUND])
        end
        if otp.expired?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:UNPROCESSABLE_ENTITY], error: 'Expired OTP' },
                                  staff, false)
          error!('Expired OTP', HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
        unless otp.otp_able.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'User not found' },
                                  staff, false)
          error!('User not found', HTTP_CODE[:NOT_FOUND])
        end

        response = { otp: otp.code, expired_at: otp.expiry }

        if otp.otp_able_type == 'TmpUser' && otp.otp_able.update!(is_otp_verified: true)
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:OK] },
                                  staff, true)
            response = response.merge(tmp_id: otp.otp_able_id)
        end

        if otp.update!(is_otp_verified: true)
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:OK] },
                                  staff, true)
        end

        status HTTP_CODE[:OK]
        response.merge(is_otp_verified: otp.reload.is_otp_verified)
      end
    end
  end
end
