# frozen_string_literal: true

module Lms
  class LibraryLocations < Lms::Base
    helpers Lms::QueryParams::LibraryLocationParams
    resources :library_locations do
      desc 'Search Library Location'
      params do
        use :pagination, max_per_page: 25
        requires :search_term, type: String
      end

      get 'search' do
        library_locations = LibraryLocation.not_deleted.where('lower(code) like :search_term',
                                           search_term: "%#{params[:search_term].downcase}%")
        Lms::Entities::LibraryLocationSearch.represent(library_locations)
      end
      desc 'Library locations list'
      params do
        use :pagination, per_page: 25
      end

      get do
        library_locations = @current_library.library_locations.not_deleted
        Lms::Entities::LibraryLocations.represent(paginate(library_locations))
      end

      desc 'Create library location'
      params do
        use :library_location_create_params
      end

      post do
        staff = @current_library.staffs.find_by(id: params[:staff_id])
        unless staff.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                  @current_library, false)
          error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
        end
        library_location = @current_library.library_locations.not_deleted.find_by(code: params[:code])
        if library_location.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:CONFLICT], error: 'CONFLICT' },
                                  staff, false)
          status HTTP_CODE[:CONFLICT]
          Lms::Entities::LibraryLocations.represent(library_location)
        else
          library_location = @current_library.library_locations.new(declared(params, include_missing: false)
                                                                      .except(:staff_id)
                                                                      .merge!(created_by_id: staff.id))
          if library_location.save!
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:OK] },
                                    staff, true)
            Lms::Entities::LibraryLocations.represent(library_location)
          end
        end
      end

      route_param :id do
        desc 'Update library location'
        params do
          use :library_location_update_params
        end

        put do
          staff = @current_library.staffs.find_by(id: params[:staff_id])
          unless staff.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                    @current_library, false)
            error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
          end
          
          library_location = @current_library.library_locations.not_deleted.find_by(id: params[:id])
          unless library_location.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Library location not found' },
                                    staff, false)
            error!('Library location not found', HTTP_CODE[:NOT_FOUND])
          end

          if library_location.update!(declared(params, include_missing: false).except(:staff_id)
                                                                           .merge!(updated_by_id: params[:staff_id]))
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:OK] },
                                    staff, true)
            Lms::Entities::LibraryLocations.represent(library_location)
          end
        end

        desc 'library location delete'
        params do
          use :library_location_delete_params
        end
        patch do
          staff = @current_library.staffs.find_by(id: params[:staff_id])
          unless staff.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                    @current_library, false)
            error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
          end
          library_location = @current_library.library_locations.not_deleted.find_by(id: params[:id])
          unless library_location.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Library location not found' },
                                    staff, false)
            error!('Library location not found', HTTP_CODE[:NOT_FOUND])
          end
          if library_location.check_biblio_items_presence
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Has associated biblio items' },
                                    staff, false)
            error!('Has associated biblio items', HTTP_CODE[:NOT_ACCEPTABLE])
          end
          if library_location.update!(is_deleted: true, updated_by_id: staff.id, deleted_at: DateTime.now)
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:OK] },
                                    staff, true)
            Lms::Entities::LibraryLocations.represent(library_location)
          end
        end
      end
    end
  end
end
