module Admin
  class Collections < Base
    include Admin::Helpers::AuthorizationHelpers
    resources :collections do

      desc 'get collection list'
      params do
        use :pagination, max_per_page:25
        optional :search_term, type: String, allow_blank: false
      end
      get do
        collections = Collection.not_deleted.all
        collections = collections.where("title LIKE ?", "%#{params[:search_term]}%") if params[:search_term].present?
        Admin::Entities::Collections.represent(paginate(collections))
      end

      route_param :id do
        desc 'get collection details'
        get do
          collection = Collection.not_deleted.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless collection.present?
          Admin::Entities::Collections.represent(collection)
        end
      end
    end
  end
end