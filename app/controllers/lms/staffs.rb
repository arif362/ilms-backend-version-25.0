# frozen_string_literal: true

module Lms
  class Staffs < Lms::Base
    helpers Lms::QueryParams::StaffParams
    resources :staffs do
      desc 'Staff Details'
      params do
        use :staff_validate_params
      end
      post 'validate' do
        staff = @current_library.staffs.library.active.find_by(email: params[:email])
        unless staff.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:BAD_REQUEST], error: 'Invalid email or password' },
                                  @current_library, false)
          error!('Invalid email or password', HTTP_CODE[:BAD_REQUEST])
        end
        unless staff.password == params[:password]
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:BAD_REQUEST], error: 'Invalid email or password' },
                                  @current_library, false)
          error!('Invalid email or password', HTTP_CODE[:BAD_REQUEST])
        end
        status HTTP_CODE[:OK]
        Lms::Entities::Staffs.represent(staff)
      end
    end
  end
end
