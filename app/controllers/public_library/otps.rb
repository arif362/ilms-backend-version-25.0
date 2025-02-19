module PublicLibrary
  class Otps < PublicLibrary::Base

    resources :otps do
      desc 'Send an otp.'
      params do
        requires :phone, type: String, allow_blank: false
      end

      route_setting :authentication, optional: true
      post '/send' do
        user = User.active.find_by(phone: params[:phone])
        user ||= TmpUser.find_by(phone: params[:phone])
        error!('User not found', HTTP_CODE[:NOT_FOUND]) unless user.present?

        if user.is_a?(User)
          user.otps.registered_user.create_otp(user.phone)
        else
          user.otps.temporary_user.create_otp(user.phone)
        end

        status HTTP_CODE[:OK]
      end

      desc 'Verify OTP.'
      params do
        requires :otp, type: String, allow_blank: false
        requires :otp_type, type: String, allow_blank: false, values: Otp.otp_types.keys
      end

      route_setting :authentication, optional: true
      post '/verify' do
        otp = Otp.send(params[:otp_type].to_sym).active.where(code: params[:otp])&.last
        error!('Otp not matched; Please resend otp again', HTTP_CODE[:NOT_FOUND]) unless otp.present?

        error!('Expired OTP', HTTP_CODE[:UNPROCESSABLE_ENTITY]) if otp.expired?
        error!('User not found', HTTP_CODE[:NOT_FOUND]) unless otp.otp_able.present?

        response = { otp: otp.code, expired_at: otp.expiry }

        if otp.otp_able_type == 'TmpUser'
          otp.otp_able.update!(is_otp_verified: true)
          response = response.merge(tmp_id: otp.otp_able_id)
        end
        otp.otp_able.user.update!(phone: otp.otp_able.phone) if otp.phone_change?

        otp.update!(is_otp_verified: true)

        status HTTP_CODE[:OK]
        response
      end

      desc 'Reset Password Otp Send'
      params do
        requires :phone, type: String, allow_blank: false
      end

      route_setting :authentication, optional: true
      post '/reset_password_otp' do
        user = User.active.find_by(phone: params[:phone])
        error!('User not found', HTTP_CODE[:NOT_FOUND]) unless user.present?

        user.otps.reset_password.create_otp(user.phone)

        status HTTP_CODE[:OK]
      end
    end
  end
end
