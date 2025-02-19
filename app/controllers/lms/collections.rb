# frozen_string_literal: true

module Lms
  class Collections < Lms::Base
    helpers Lms::QueryParams::CollectionParams

    resource :collections do
      desc 'Search Collection'
      params do
        use :pagination, max_per_page: 25
        requires :search_term, type: String
      end

      get 'search' do
        collection = Collection.not_deleted.where('lower(title) like :search_term',
                                           search_term: "%#{params[:search_term].downcase}%")
        Lms::Entities::CollectionSearch.represent(collection)
      end
      desc 'search title list'
      params do
        use :pagination, per_page: 25
        use :collection_title_search_params
      end
      get do
        collections = Collection.not_deleted
        collections = Collection.not_deleted.where(' title LIKE ?', "%#{params[:title]}%") if params[:title].present?
        Lms::Entities::CollectionDetails.represent(paginate(collections))
      end

      desc 'Create a collection'
      params do
        use :collection_create_params
      end
      post do
        staff = Staff.find_by(id: params[:staff_id])
        unless staff.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILS' },
                                  @current_library, false)
          error!('Staff doesn\'t exist in ILS', HTTP_CODE[:NOT_FOUND])
        end

        collection = Collection.not_deleted.find_by(title: params[:title])

        if collection.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:CONFLICT] },
                                  staff, false)
          status HTTP_CODE[:CONFLICT]
          present collection, with: Lms::Entities::CollectionDetails
        else
          collection = Collection.new(declared(params,
                                               include_missing: false).except(:staff_id).merge!(created_by_id: staff.id))
          if collection.save!
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:CREATED] },
                                    staff, true)
            present collection, with: Lms::Entities::CollectionDetails
          end
        end
      end

      route_param :id do
        desc 'Update a collection'
        params do
          use :collection_update_params
        end
        put do
          staff = Staff.find_by(id: params[:staff_id])
          unless staff.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILS' },
                                    @current_library, false)
            error!('Staff doesn\'t exist in ILS', HTTP_CODE[:NOT_FOUND])
          end

          collection = Collection.not_deleted.find_by(id: params[:id])
          unless collection.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Collection not found' },
                                    staff, false)
            error!('Collection not found', HTTP_CODE[:NOT_FOUND])
          end

          if collection.update!(declared(params,
                                         include_missing: false).except(:staff_id).merge!(updated_by_id: staff.id))
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:OK] },
                                    staff, true)
            present collection, with: Lms::Entities::CollectionDetails
          end
        end

        desc 'Delete a collection'
        params do
          use :collection_delete_params
        end
        delete do
          staff = Staff.find_by(id: params[:staff_id])
          unless staff.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILS' },
                                    @current_library, false)
            error!('Staff doesn\'t exist in ILS', HTTP_CODE[:NOT_FOUND])
          end

          collection = Collection.not_deleted.find_by(id: params[:id])
          unless collection.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Collection not found' },
                                    staff, false)
            error!('Collection not found', HTTP_CODE[:NOT_FOUND])
          end

          collection.is_deleted = true
          collection.updated_by_id = staff.id

          if collection.save!
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:OK] },
                                    staff, true)
            present collection, with: Lms::Entities::CollectionDetails
          end
        end
      end
    end
  end
end
