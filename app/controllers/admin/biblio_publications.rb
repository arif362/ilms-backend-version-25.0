module Admin
  class BiblioPublications < Base
    include Admin::Helpers::AuthorizationHelpers

    resources :publications do
      desc 'get publication list'

      params do
        use :pagination, max_per_page: 25
        optional :search_term, type: String, allow_blank: false
      end

      get do
        publications = BiblioPublication.not_deleted.all
        authorize publications, :read?
        publications = publications.where("title LIKE ?", "%#{params[:search_term]}%") if params[:search_term].present?
        Admin::Entities::BiblioPublications.represent(paginate(publications))
      end

      route_param :id do
        desc 'get publication details'

        get do
          publication = BiblioPublication.not_deleted.find_by(id: params[:id])
          authorize publication, :read?
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless publication.present?
          Admin::Entities::BiblioPublications.represent(publication)
        end
      end
    end
  end
end
