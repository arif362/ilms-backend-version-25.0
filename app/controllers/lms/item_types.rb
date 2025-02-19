# frozen_string_literal: true

module Lms
  class ItemTypes < Lms::Base
    helpers Lms::QueryParams::ItemTypeParams
    resources :item_types do
      desc 'Search item type'
      params do
        use :pagination, max_per_page: 25
        requires :search_term, type: String
      end

      get 'search' do
        item_type = ItemType.not_deleted.where('lower(title) like :search_term',
                                           search_term: "%#{params[:search_term].downcase}%")
        Lms::Entities::ItemTypeSearch.represent(item_type)
      end

      desc 'Create item type'
      params do
        use :item_type_create_params
      end

      post do
        staff = @current_library.staffs.find_by(id: params[:staff_id])
        unless staff.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                  @current_library, false)
          error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
        end
        item_type = ItemType.not_deleted.find_by(title: params[:title])
        if item_type.present?
          status HTTP_CODE[:CONFLICT]
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:CONFLICT] },
                                  staff, false)
          Lms::Entities::ItemTypes.represent(item_type)
        else
          item_type = ItemType.new(declared(params, include_missing: false).except(:staff_id)
                                                                           .merge!(created_by_id: staff.id))
          if item_type.save!
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:OK] },
                                    staff, true)
            Lms::Entities::ItemTypes.represent(item_type)
          end
        end
      end

      route_param :id do
        desc 'Update item type'
        params do
          use :item_type_update_params
        end

        put do
          staff = @current_library.staffs.find_by(id: params[:staff_id])

          unless staff.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                    staff, false)
            error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
          end

          item_type = ItemType.not_deleted.find_by(id: params[:id])
          unless item_type.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Item type not found' },
                                    staff, false)
            error!('Item type not found', HTTP_CODE[:NOT_FOUND])
          end

          if item_type.update!(declared(params, include_missing: false).except(:staff_id)
                                                                    .merge!(updated_by_id: params[:staff_id]))
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:OK] },
                                    staff, true)
            Lms::Entities::ItemTypes.represent(item_type)
          end
        end

        desc 'item type delete'
        params do
          use :item_type_delete_params
        end
        delete do
          staff = @current_library.staffs.find_by(id: params[:staff_id])
          unless staff.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                    staff, false)
            error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
          end

          item_type = ItemType.not_deleted.find_by(id: params[:id])
          unless item_type.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Item type not found' },
                                    staff, false)
            error!('Item type not found', HTTP_CODE[:NOT_FOUND])
          end
          unless item_type.biblios.blank?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Has associated biblios' },
                                    staff, false)
            error!('Has associated biblios', HTTP_CODE[:NOT_ACCEPTABLE])
          end

          if item_type.update!(is_deleted: true, updated_by_id: staff.id, deleted_at: DateTime.now)
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:OK] },
                                    staff, true)
            Lms::Entities::ItemTypes.represent(item_type)
          end
        end
      end
    end
  end
end
