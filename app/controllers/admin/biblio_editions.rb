module  Admin
  class BiblioEditions < Base
    include Admin::Helpers::AuthorizationHelpers

    resources :biblio_editions do
      desc 'get biblio edition list'

      params do
        use :pagination, max_per_page: 25
        optional :search_term, type: String, allow_blank: false
      end

      get do
        biblio_editions = BiblioEdition.not_deleted.all
        authorize biblio_editions, :read?
        biblio_editions = biblio_editions.where("title LIKE ?", "%#{params[:search_term]}%") if params[:search_term].present?
        Admin::Entities::BiblioEditions.represent(paginate(biblio_editions))
      end

      route_param :id do
        desc 'get biblio edition details'
        get do
          biblio_edition = BiblioEdition.not_deleted.find_by(id: params[:id])
          authorize biblio_edition, :read?
          error!('not found', HTTP_CODE[:NOT_FOUND]) unless biblio_edition.present?
          Admin::Entities::BiblioEditions.represent(biblio_edition)
        end
      end
    end
  end
end