module Admin
  class BiblioStatuses < Base
    include Admin::Helpers::AuthorizationHelpers
    resources :biblio_statuses do
      desc "get biblio status list"

      params do
        use :pagination, max_per_page: 25
        optional :search_term, type: String, allow_blank: false
      end
      get do
        biblio_statuses = BiblioStatus.all
        biblio_statuses = biblio_statuses.where("title LIKE ?", "%#{params[:search_term]}%") if params[:search_term].present?
        Admin::Entities::BiblioStatuses.represent(paginate(biblio_statuses))
      end

      route_param :id do
        desc "get biblio status details"

        get do
          biblio_status = BiblioStatus.find_by(id: params[:id])
          error!("not found", HTTP_CODE[:NOT_FOUND]) unless biblio_status.present?
          Admin::Entities::BiblioStatuses.represent(biblio_status)
        end
      end
    end
  end
end

