module Admin
  class LibraryLocations < Base
    include Admin::Helpers::AuthorizationHelpers

    resources :library_locations do
      desc 'get library location list'

      params do
        use :pagination, max_per_page: 25
        optional :search_term, type: String, allow_blank: false
      end
      get do
        library_locations = LibraryLocation.not_deleted.all
        authorize library_locations, :read?
        library_locations = library_locations.where("code LIKE ?", "%#{params[:search_term]}%") if params[:search_term].present?
        Admin::Entities::LibraryLocations.represent(paginate(library_locations))
      end

      route_param :id do
        desc 'get library location details'

        get do
          library_location = LibraryLocation.not_deleted.find_by(id: params[:id])
          authorize library_location, :read?
          error!('not found', HTTP_CODE[:NOT_FOUND]) unless library_location.present?
          Admin::Entities::LibraryLocations.represent(library_location)
        end
      end

    end

  end
end

