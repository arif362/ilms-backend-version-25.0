# frozen_string_literal: true

module Admin
  class BiblioItems < Admin::Base
    resources :biblio_items do
      include Admin::Helpers::AuthorizationHelpers
      desc 'Biblio Item List'
      params do
        use :pagination, per_page: 25
        optional :search_term, type: String
      end
      get do
        biblio_items = BiblioItem.all
        if params[:search_term].present?
          biblio_items = biblio_items.where('lower(accession_no) like :search_term or lower(central_accession_no) like :search_term',
                                            search_term: "%#{params[:search_term].downcase}%")
        end
        Admin::Entities::BiblioItems.represent(paginate(biblio_items.order(id: :desc)))
      end

      route_param :id do
        desc 'Biblio Item details'
        get do
          biblio_item = BiblioItem.find_by(id: params[:id])
          error!('Biblio item not found', HTTP_CODE[:NOT_FOUND]) unless biblio_item.present?
          Admin::Entities::BiblioItemDetails.represent(biblio_item)
        end
      end
    end
  end
end
