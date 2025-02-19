module PublicLibrary
  class Carts < PublicLibrary::Base
    resources :carts do
      desc 'Add Item'
      params do
        requires :biblio_slug, type: String, allow_blank: false
      end
      post 'add_item' do
        error!('Need Membership', HTTP_CODE[:NOT_ACCEPTABLE]) unless @current_user.membership?

        cart = @current_user.current_cart

        biblio = Biblio.find_by(slug: params[:biblio_slug])
        error!('Biblio Not Found', HTTP_CODE[:NOT_FOUND]) unless biblio.present?

        item = cart.cart_items.find_by(biblio_id: biblio.id)
        error!('Already in cart', HTTP_CODE[:NOT_ACCEPTABLE]) if item.present?

        if (@current_user.items_on_hand + cart.cart_items.count) > ENV['MAX_BORROW'].to_i
          error!("You can not borrow more than #{ENV['MAX_BORROW'].to_i} items", HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        biblio_library = biblio.biblio_libraries.find_by('available_quantity > 0')
        error!('Biblio not available in any library', HTTP_CODE[:NOT_FOUND]) if biblio_library.nil?

        cart.cart_items.build(biblio:)
        cart.save!
        PublicLibrary::Entities::Carts.represent(cart, locale: @locale, request_source: @request_source)
      end

      desc 'Cart Details'
      get :details do
        cart = @current_user.current_cart
        PublicLibrary::Entities::Carts.represent(cart, locale: @locale, request_source: @request_source)
      end

      desc 'Remove Item'
      params do
        requires :cart_item_id, type: Integer
      end
      delete :remove do
        cart = @current_user.current_cart
        cart.cart_items.find_by(id: params[:cart_item_id])&.destroy!
        PublicLibrary::Entities::Carts.represent(cart, locale: @locale, request_source: @request_source)
      end

      desc 'Empty cart'
      delete do
        cart = @current_user.current_cart
        cart.cart_items.destroy_all
        status HTTP_CODE[:OK]
      end
    end
  end
end
