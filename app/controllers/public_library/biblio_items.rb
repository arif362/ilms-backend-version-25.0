# frozen_string_literal: true

module PublicLibrary
  class BiblioItems < PublicLibrary::Base
    resources :biblio_items do
      helpers PublicLibrary::QueryParams::ReviewParams

      route_param :barcode do
        get do
          biblio_item = BiblioItem.find_by(barcode: params[:barcode])
          error!('biblio_item not found', HTTP_CODE[:NOT_FOUND]) unless biblio_item.present?

          PublicLibrary::Entities::BiblioList.represent(biblio_item.biblio,
                                                        locale: @locale, request_source: @request_source,
                                                        current_user: @current_user)
        end

      end

    end
  end
end
