module PublicLibrary
  class Orders < PublicLibrary::Base
    resources :orders do
      desc 'Checkout Order'
      params do
        requires :delivery_type, type: String, values: %w[home_delivery pickup], allow_blank: false
        optional :address_type, type: String, values: %w[present permanent others], allow_blank: false
        optional :recipient_name, type: String
        optional :recipient_phone, type: String, regexp: /(\A(\+88|0088)?(01)[3456789](\d){8})\z/
        optional :address, type: String
        optional :division_id, type: Integer
        optional :district_id, type: Integer
        optional :thana_id, type: Integer
        optional :pick_up_library_id, type: Integer
        optional :delivery_area, type: String
        optional :delivery_area_id, type: Integer
        optional :note, type: String
        optional :save_address, type: Boolean, allow_blank: false
        optional :address_name, type: String, allow_blank: false
        requires :cart_items, type: Array do
          requires :biblio_id, type: Integer
          requires :library_id, type: Integer
        end
      end
      post do
        error!('Need Membership', HTTP_CODE[:NOT_ACCEPTABLE]) unless @current_user.membership?
        cart = @current_user.current_cart
        member = @current_user.member

        error!('Cart Empty', HTTP_CODE[:NOT_ACCEPTABLE]) if cart.cart_items.empty?
        error!('You have pending invoice', HTTP_CODE[:FORBIDDEN]) if @current_user.invoices&.fine&.pending.present?

        if (@current_user.items_on_hand + cart.cart_items.count) > ENV['MAX_BORROW'].to_i
          error!("You can not borrow more than #{ENV['MAX_BORROW'].to_i} items", HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        response_orders = []
        if params[:delivery_type] == 'home_delivery' && !(params[:address_type].present? && params[:address].present? && params[:recipient_name].present? && params[:recipient_phone].present? && params[:division_id].present? && params[:district_id].present? && params[:thana_id].present?)
          error!('Must provide all delivery info for home delivery', HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        if params[:delivery_type] == 'home_delivery' && params[:address_type] == 'others'
          unless params[:division_id].present?
            error!('Recipient delivery division is required', HTTP_CODE[:BAD_REQUEST])
          end
          unless params[:district_id].present?
            error!('Recipient delivery district is required', HTTP_CODE[:BAD_REQUEST])
          end
          unless params[:thana_id].present?
            error!('Recipient delivery thana is required', HTTP_CODE[:BAD_REQUEST])
            thana = Thana.find_by(id: params[:thana_id])

            error!('Thana not found', HTTP_CODE[:NOT_FOUND]) unless thana.present?

          end
        elsif params[:delivery_type] == 'home_delivery' && params[:address_type] == 'permanent'
          params[:division_id] = member.permanent_division_id
          params[:district_id] = member.permanent_district_id
          params[:thana_id] = member.permanent_thana_id
          params[:delivery_area] = @current_user.saved_addresses&.permanent&.last&.delivery_area
          params[:delivery_area_id] = @current_user.saved_addresses&.permanent&.last&.delivery_area_id
        elsif params[:delivery_type] == 'home_delivery' && params[:address_type] == 'present'
          params[:division_id] = member.present_division_id
          params[:district_id] = member.present_district_id
          params[:thana_id] = member.present_thana_id
          params[:delivery_area] = @current_user.saved_addresses&.present&.last&.delivery_area
          params[:delivery_area_id] = @current_user.saved_addresses&.present&.last&.delivery_area_id
        end

        if params[:delivery_type] == 'pickup' && !params[:pick_up_library_id].present?
          error!('Pick up library required for self pickup order', HTTP_CODE[:NOT_ACCEPTABLE])
        end


        orders = {}
        params[:cart_items].each do |cart_item|
          item = cart.cart_items.find_by(biblio_id: cart_item[:biblio_id])
          error!('Biblio not found in your cart', HTTP_CODE[:NOT_FOUND]) unless item.present?

          biblio = Biblio.find_by(id: cart_item[:biblio_id])
          error!("Biblio not found for the id : #{cart_item[:biblio_id]}", HTTP_CODE[:NOT_FOUND]) unless biblio.present?

          library = Library.find_by(id: cart_item[:library_id])
          error!("Library not found for the id : #{cart_item[:library_id]}", HTTP_CODE[:NOT_FOUND]) unless library.present?
          params[:redx_pickup_store_id] = library.redx_pickup_store_id if params[:delivery_type] == 'home_delivery'

          biblio_library = biblio.biblio_libraries&.find_by(library:, available_quantity: 1...)
          error!("'#{biblio.title}' not available in '#{library.name}'", HTTP_CODE[:NOT_FOUND]) if biblio_library.nil?

          order_library_id = library.id
          if orders[order_library_id].present?
            orders[order_library_id] << cart_item[:biblio_id]
          else
            orders[order_library_id] = [cart_item[:biblio_id]]
          end
        end

        order_place_status = OrderStatus.get_status(OrderStatus.status_keys[:order_placed])
        orders.each do |order_library_id, biblio_ids|
          order = @current_user.orders.build(
            library_id: order_library_id,
            pick_up_library_id: params[:pick_up_library_id],
            delivery_type: params[:delivery_type],
            recipient_name: params[:recipient_name],
            recipient_phone: params[:recipient_phone],
            address: params[:address],
            address_type: params[:address_type],
            division_id: params[:division_id],
            district_id: params[:district_id],
            delivery_area: params[:delivery_area],
            delivery_area_id: params[:delivery_area_id],
            pickup_store_id: params[:redx_pickup_store_id],
            thana_id: params[:thana_id],
            note: params[:note],
            order_status_id: order_place_status.id
          )

          biblio_ids.each do |biblio_id|
            order.line_items.build(
              biblio_id:,
              quantity: 1
            )
          end
          order.save!
          response_orders << order
        end

        cart.cart_items.destroy_all

        if params[:save_address].present? && params[:address_type] == 'others'
          error!('Address title/name is required', HTTP_CODE[:BAD_REQUEST]) unless params[:address_name].present?

          if params[:delivery_type] == 'home_delivery' && params[:delivery_area].blank? && params[:delivery_area_id].blank?
            error!('delivery_area_name and id are required for home delivery', HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          SavedAddress.add_address(@current_user, params[:address_name], params[:address], params[:division_id], params[:district_id], params[:thana_id], params[:recipient_name], params[:recipient_phone], params[:delivery_area_id], params[:delivery_area])
        end
        CreateUserSuggestionJob.perform_later(user: @current_user,
                                              biblio_ids: response_orders.map { |order| order.line_items.pluck(:biblio_id) }.flatten,
                                              action_type: 'borrow')
        PublicLibrary::Entities::Orders.represent(response_orders, locale: @locale)
      end

      desc 'My order list'
      params do
        use :pagination, per_page: 25
        optional :unique_id, type: String
        optional :is_processing, type: Boolean, values: [true, false]
        optional :order_status_id, type: Integer
      end
      get do
        orders = @current_user.orders
        if params[:unique_id].present?
          orders = if params[:unique_id].downcase.starts_with?('O', 'o')
                     orders.where(id: params[:unique_id][4..].to_i)
                   else
                     orders.where(id: params[:unique_id].to_i)
                   end
        end

        orders = orders.where(order_status_id: OrderStatus.under_process_orders) if params[:is_processing].present?
        orders = orders.where(order_status_id: params[:order_status_id]) if params[:order_status_id].present?
        orders = orders.order(id: :desc)
        PublicLibrary::Entities::Orders.represent(paginate(orders), locale: @locale, request_source: @request_source)
      end

      desc 'Order status list for dropdown'
      get :statuses do
        PublicLibrary::Entities::OrderStatuses.represent(OrderStatus.all, locale: @locale)
      end

      route_param :id do
        desc 'My order details'
        get do
          order = @current_user.orders.find_by(id: params[:id])
          error!('Order not found', HTTP_CODE[:NOT_FOUND]) if order.nil?

          PublicLibrary::Entities::OrderDetails.represent(order, locale: @locale, request_source: @request_source)
        end

        desc 'Track order'
        get 'track' do
          order = @current_user.orders.find_by(id: params[:id])
          error!('Order not found', HTTP_CODE[:NOT_FOUND]) if order.nil?
          order_statuses = order.order_status_changes.order(id: :asc)
          PublicLibrary::Entities::OrderStatusChanges.represent(order_statuses, locale: @locale)
        end

        desc 'cancel order'
        patch 'cancel' do
          status = OrderStatus.get_status('order_placed')
          order = Order.find_by(id: params[:id], order_status: status)
          error!('Order cannot be cancelled', HTTP_CODE[:NOT_ACCEPTABLE]) if order.nil?
          order.update!(order_status: OrderStatus.get_status('cancelled'))
          PublicLibrary::Entities::OrderDetails.represent(order, locale: @locale, request_source: @request_source)
        end
      end
    end
  end
end
