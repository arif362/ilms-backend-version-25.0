# frozen_string_literal: true

module Admin
  class StaffAuth < Admin::Base
    resources :staff_auth do
      desc 'Staff Login'
      params do
        requires :email, type: String
        requires :password, type: String
      end
      route_setting :authentication, optional: true
      post :login do
        @staff = Staff.admin.active.find_by(email: params[:email])
        error!('Invalid email or password.', HTTP_CODE[:BAD_REQUEST]) unless @staff.present?
        if !@staff.retired_date.nil? && (@staff.retired_date <= DateTime.now)
          error!('You Have Already Retired.', HTTP_CODE[:BAD_REQUEST])
        end
        if @staff.password == params[:password]
          AuthToken.generate_staff_token(@staff).merge(
            user: {
              id: @staff.id,
              name: @staff.name,
              email: @staff.email,
              role: @staff.role&.title,
              permissions: @staff.role&.permission_codes
            }
          )
        else
          error!('Invalid email or password.', HTTP_CODE[:BAD_REQUEST])
        end
      end

      desc 'Staff Logout'
      delete :logout do
        error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless AuthToken.remove_access_token(@current_staff)
        status HTTP_CODE[:OK]
      end
    end
  end
end
