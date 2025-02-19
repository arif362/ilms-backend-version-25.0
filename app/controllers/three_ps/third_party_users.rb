# frozen_string_literal: true

module ThreePs
  class ThirdPartyUsers < ThreePs::Base

    resources :third_party_users do

      desc 'User Login'
      params do
        requires :email, type: String
        requires :password, type: String
      end

      route_setting :authentication, optional: true
      post :login do
        @user = ThirdPartyUser.active.find_by(email: params[:email])
        error!('Invalid email or password', HTTP_CODE[:FORBIDDEN]) unless @user.present? && @user.is_active?
        error!('Invalid email or password.', HTTP_CODE[:FORBIDDEN]) unless @user.password == params[:password]

        status HTTP_CODE[:OK]
        AuthToken.generate_staff_token(@user)
      end

      desc 'User Logout'
      delete :logout do
        error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless AuthToken.remove_access_token(@current_user)
        status HTTP_CODE[:OK]
      end
    end
  end
end
