# frozen_string_literal: true

module Lms
  class BorrowPolicies < Lms::Base
    helpers Lms::QueryParams::BorrowPolicyParams

    resources :borrow_policies do
      desc 'Borrow policy List'
      params do
        use :pagination, max_per_page: 25
      end

      get do
        borrow_policies = BorrowPolicy.not_deleted.all
        Lms::Entities::BorrowPolicy.represent(paginate(borrow_policies.order(id: :desc)))
      end

      desc 'Borrow policy create'
      params do
        use :borrow_policy_create_params
      end

      post do
        library_staff = @current_library.staffs.library.find_by(id: params[:staff_id])
        unless library_staff.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff not valid for this library' },
                                  @current_library, false)
          error!('Staff not valid for this library', HTTP_CODE[:NOT_FOUND])
        end
        item_type = ItemType.find_by(id: params[:item_type_id])
        unless item_type.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Item type not found' },
                                  library_staff, false)
          error!('Item type not found', HTTP_CODE[:NOT_FOUND])
        end
        borrow_policy = BorrowPolicy.not_deleted.find_by(item_type_id: params[:item_type_id],
                                                         category: params[:category])
        if borrow_policy.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:CONFLICT] },
                                  library_staff, false)
          status HTTP_CODE[:CONFLICT]
          Lms::Entities::BorrowPolicy.represent(borrow_policy)
        else
          borrow_policy = BorrowPolicy.new(declared(params, include_missing: false).except(:staff_id)
                                             .merge!(created_by_id: library_staff.id))
          if borrow_policy.save!
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:CREATED] },
                                    library_staff, true)
            Lms::Entities::BorrowPolicy.represent(borrow_policy)
          end
        end
      end

      route_param :id do
        desc 'Borrow policy details'

        get do
          borrow_policy = BorrowPolicy.not_deleted.find_by(id: params[:id])
          unless borrow_policy.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Borrow policy not found' },
                                    @current_library, false)
            error!('Borrow policy not found', HTTP_CODE[:NOT_FOUND])
          end
          Lms::Entities::BorrowPolicy.represent(borrow_policy)
        end

        desc 'Borrow policy update'
        params do
          use :borrow_policy_update_params
        end

        put do
          library_staff = @current_library.staffs.library.find_by(id: params[:staff_id])
          unless library_staff.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff not valid for this library' },
                                    @current_library, false)
            error!('Staff not valid for this library', HTTP_CODE[:NOT_FOUND])
          end
          borrow_policy = BorrowPolicy.not_deleted.find_by(id: params[:id])
          unless borrow_policy.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Borrow policy not found' },
                                    library_staff, false)
            error!('Borrow policy not found', HTTP_CODE[:NOT_FOUND])
          end
          if borrow_policy.update!(declared(params, include_missing: false).except(:staff_id).merge!(updated_by_id: staff.id))
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:OK] },
                                    library_staff, true)
            Lms::Entities::BorrowPolicy.represent(borrow_policy)
          end
        end

        desc 'Borrow policy delete'
        params do
          use :borrow_policy_delete_params
        end
        delete do
          borrow_policy = BorrowPolicy.find_by(id: params[:id])
          library_staff = @current_library.staffs.library.find_by(id: params[:staff_id])
          unless library_staff.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff not valid for this library' },
                                    @current_library, false)
            error!('Staff not valid for this library', HTTP_CODE[:NOT_FOUND])
          end
          unless borrow_policy.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Borrow policy not found' },
                                    library_staff, false)
            error!('Borrow policy not found', HTTP_CODE[:NOT_FOUND])
          end
          if borrow_policy.update!(is_deleted: true, updated_by_id: library_staff.id)
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:OK] },
                                    library_staff, true)
            Lms::Entities::BorrowPolicy.represent(borrow_policy)
          end
        end
      end
    end
  end
end
