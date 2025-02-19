module Admin
  class BiblioClassificationSources < Base
    include Admin::Helpers::AuthorizationHelpers

    resources :biblio_classification_sources do
      desc 'get biblio classification source list'
      params do
        use :pagination, max_per_page: 25
        optional :search_term, type: String, allow_blank: false
      end
      get do
        biblio_classification_sources = BiblioClassificationSource.not_deleted.all
        biblio_classification_sources = biblio_classification_sources.where("title LIKE ?", "%#{params[:search_term]}%") if params[:search_term].present?
        authorize biblio_classification_sources, :read?
        Admin::Entities::BiblioClassificationSources.represent(paginate(biblio_classification_sources))
      end

      route_param :id do
        desc 'get biblio classification source details'

        get do
          biblio_classification_source = BiblioClassificationSource.not_deleted.find_by(id: params[:id])
          authorize biblio_classification_source, :read?
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless biblio_classification_source.present?
          Admin::Entities::BiblioClassificationSources.represent(biblio_classification_source)
        end
      end
    end
  end
end