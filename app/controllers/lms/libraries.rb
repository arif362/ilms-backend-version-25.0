# frozen_string_literal: true

module Lms
  class Libraries < Lms::Base
    resources :libraries do
      desc 'Library Login'
      params do
        requires :username, type: String
        requires :password, type: String
      end

      route_setting :authentication, optional: true
      post :login do
        @library = Library.active.find_by(username: params[:username])
        unless @library.present? && @library.is_active?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:UNAUTHORIZED], error: 'Invalid username or password' },
                                  @current_library, false)
          error!('Invalid username or password', HTTP_CODE[:UNAUTHORIZED])
        end
        unless @library.password == params[:password]
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:UNAUTHORIZED], error: 'Invalid username or password' },
                                  @current_library, false)
          error!('Invalid username or password.', HTTP_CODE[:UNAUTHORIZED])
        end

        status 200
        AuthToken.generate_staff_token(@library)
      end

      desc 'Library Logout'
      delete :logout do
        unless AuthToken.remove_access_token(@current_library)
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Not Found' },
                                  @current_library, false)
          error!('Not Found', HTTP_CODE[:NOT_FOUND])
        end
        status HTTP_CODE[:NOT_FOUND]
      end
    end
  end
end
