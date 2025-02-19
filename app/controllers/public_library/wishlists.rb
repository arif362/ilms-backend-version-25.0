module PublicLibrary
  class Wishlists < PublicLibrary::Base
    resources :wishlists do
      desc 'Wishlisted biblios'
      params do
        use :pagination, per_page: 25
      end
      get do
        wishlists = @current_user.biblio_wishlists.all
        PublicLibrary::Entities::Wishlists.represent(paginate(wishlists),
                                                     locale: @locale, request_source: @request_source,
                                                     current_user: @current_user)
      end

      desc 'Add a wishlist item'
      params do
        requires :biblio_slug, type: String, allow_blank: false
      end
      post do
        biblio = Biblio.find_by(slug: params[:biblio_slug])
        error!('Biblio not found', HTTP_CODE[:NOT_FOUND]) unless biblio.present?
        error!('Book already wishlisted', HTTP_CODE[:NOT_ACCEPTABLE]) unless @current_user.biblio_wishlists.find_by(biblio_id: biblio.id).blank?
        wishlist = @current_user.biblio_wishlists.find_or_create_by!(biblio_id: biblio.id)
        PublicLibrary::Entities::Wishlists.represent(wishlist, locale: @locale, request_source: @request_source,
                                                               current_user: @current_user)
      end

      route_param :biblio_slug do
        desc 'Remove from wishlist'
        delete do
          biblio = Biblio.find_by(slug: params[:biblio_slug])
          error!('Biblio not found', HTTP_CODE[:NOT_FOUND]) unless biblio.present?
          wishlist = @current_user.biblio_wishlists.find_by(biblio_id: biblio.id)
          error!('Biblio not found in the wishlist', HTTP_CODE[:NOT_FOUND]) unless wishlist.present?
          wishlist.destroy!
          status HTTP_CODE[:OK]
        end
      end
    end
  end
end
