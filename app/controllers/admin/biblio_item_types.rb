module Admin
  class BiblioItemTypes < Base
    include Admin::Helpers::AuthorizationHelpers
    resources :biblio_item_types do

      desc 'get biblio item type list'
      params do
        use :pagination, max_per_page:25
        optional :search_term, type: String, allow_blank: false
      end

      get do
        biblio_item_types = ItemType.not_deleted.all
        biblio_item_types = biblio_item_types.where("title LIKE ?", "%#{params[:search_term]}%") if params[:search_term].present?
        Admin::Entities::BiblioItemTypes.represent(biblio_item_types)
      end

      route_param :id do
        desc 'get biblio item type details'

        get do
          biblio_item_type = ItemType.not_deleted.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless biblio_item_type.present?
          Admin::Entities::BiblioItemTypes.represent(biblio_item_type)
        end
      end
    end

  end
end