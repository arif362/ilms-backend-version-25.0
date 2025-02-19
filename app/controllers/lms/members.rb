# frozen_string_literal: true

module Lms
  class Members < Lms::Base
    helpers Lms::QueryParams::MemberParams
    resources :members do

      desc 'Member update'

      params do
        use :member_update_params
      end

      route_param :id do

        put do
          library_staff = @current_library.staffs.library.find_by(id: params[:staff_id])
          params_except_images = params.except(:nid_front_image_file, :nid_back_image_file, :profile_image_file, :birth_certificate_image_file, :student_id_image_file)

          unless library_staff.present?
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff not valid for this library' },
                                    @current_library,
                                    false)
            error!('Staff not valid for this library', HTTP_CODE[:NOT_FOUND])
          end

          member = Member.find_by(id: params[:id])
          unless member.present?
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Member not found' },
                                    library_staff,
                                    false)
            error!('Member not found', HTTP_CODE[:NOT_FOUND])
          end

          member.update!(declared(params).merge!(updated_by_id: library_staff.id))

          LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                  { status_code: HTTP_CODE[:OK] },
                                  library_staff, true)

          Lms::Entities::MemberDetails.represent(member)
        end
      end

    end
  end
end
