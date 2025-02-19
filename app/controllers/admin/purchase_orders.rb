# frozen_string_literal: true

module Admin
  class PurchaseOrders < Admin::Base
    resources :purchase_orders do
      include Admin::Helpers::AuthorizationHelpers
      helpers Admin::QueryParams::PurchaseOrderParams

      desc 'publisher list based on memorandum'
      params do
        requires :memorandum_id, type: Integer, allow_blank: false
      end

      get 'publisher_list' do
        memorandum = Memorandum.find_by(id: params[:memorandum_id])
        error!('memorandum not found', HTTP_CODE[:NOT_ACCEPTABLE]) unless memorandum.present?

        publishers = memorandum.publishers.order(:publication_name) if memorandum.publishers.present?

        if publishers.blank?
          error!('there are no publishers for this memorandum', HTTP_CODE[:NOT_ACCEPTABLE])
        else
          Admin::Entities::PublishersDropdown.represent(publishers)
        end
      end

      desc 'publisher biblio list'

      params do
        requires :publisher_id, type: Integer, allow_blank: false
        requires :memorandum_id, type: Integer, allow_blank: false
      end

      get 'publisher_biblios' do
        memorandum = Memorandum.find_by(id: params[:memorandum_id])
        error!('publisher not found', HTTP_CODE[:NOT_ACCEPTABLE]) unless memorandum.present?

        publisher = memorandum.publishers.find_by(id: params[:publisher_id])
        error!('publisher not found', HTTP_CODE[:NOT_ACCEPTABLE]) unless publisher.present?


        publisher_biblio = publisher.publisher_biblios.where(is_shortlisted: true)
        Admin::Entities::PublisherBiblios.represent(publisher_biblio)
      end


      desc 'Purchase Order List'
      params do
        use :pagination, per_page: 25
        optional :status, type: String, values: PurchaseOrderStatus::STATUSES.keys.map(&:to_s)
      end
      get do
        purchase_orders = if params[:status].present?
                            PurchaseOrder.not_deleted.where(purchase_order_status: PurchaseOrderStatus.get_status(params[:status]))
                          else
                            PurchaseOrder.not_deleted.all
                          end
        authorize purchase_orders, :read?
        Admin::Entities::PurchaseOrders.represent(paginate(purchase_orders.order(id: :desc)))
      end

      desc 'Create Purchase Order'
      params do
        use :purchase_order_create_params
      end

      post do
        memorandum = Memorandum.find_by(id: params[:memorandum_id])
        error!('memorandum not found', HTTP_CODE[:NOT_ACCEPTABLE]) unless memorandum.present?
        publisher = Publisher.find_by(id: params[:publisher_id])
        error!('publisher not found', HTTP_CODE[:NOT_ACCEPTABLE]) unless publisher.present?

        memorandum_publisher = MemorandumPublisher.find_by(memorandum_id: memorandum.id, publisher_id: publisher.id)


        error!('invalid memorandum or publisher', HTTP_CODE[:NOT_ACCEPTABLE]) if memorandum_publisher.nil?

        if memorandum_publisher.has_purchase_order?
          error!('memorandum publisher already has purchase order', HTTP_CODE[:NOT_ACCEPTABLE])
        end

        purchase_order_status = PurchaseOrderStatus.get_status(PurchaseOrderStatus.status_keys[:pending])
        error!('Purchase Order Status Not Found', HTTP_CODE[:NOT_FOUND]) unless purchase_order_status.present?
        purchase_order = PurchaseOrder.new(declared(params).merge(created_by_id: @current_staff.id, memorandum_publisher:,
                                                                  purchase_order_status_id: purchase_order_status.id).except(:po_line_item_params))
        authorize purchase_order, :create?
        line_item_params = params[:po_line_item_params]
        line_item_params.each do |line_item|
          publisher_biblio = memorandum_publisher.publisher_biblios.find_by(id: line_item['publisher_biblio_id'])
          unless publisher_biblio.present?
            error!("Publisher Biblio not found under the memorandum_publisher : #{memorandum_publisher.id}", HTTP_CODE[:NOT_FOUND])
          end

          error!('quantity should be greater than 0') unless (line_item['quantity']).positive?
          error!('price should be greater than 0') unless (line_item['price']).positive?
          quantity = line_item['quantity']
          price = line_item['price']

          po_line_item = purchase_order.po_line_items.new(publisher_biblio:,
                                                          quantity:,
                                                          price:,
                                                          sub_total: purchase_order.sub_total_calculation(price, quantity),
                                                          bar_code: publisher_biblio.isbn)
          po_line_item.save!
        end
        Admin::Entities::PurchaseOrderDetails.represent(purchase_order) if purchase_order.save!
      end

      route_param :id do
        desc 'Purchase Order Details'

        get do
          purchase_order = PurchaseOrder.not_deleted.find_by(id: params[:id])
          error!('Not found', HTTP_CODE[:NOT_FOUND]) unless purchase_order.present?
          authorize purchase_order, :read?
          Admin::Entities::PurchaseOrderDetails.represent(purchase_order)
        end

        desc 'Purchase Order update'
        params do
          use :purchase_order_update_params
        end

        put do
          purchase_order = PurchaseOrder.find_by(id: params[:id])
          error!('Purchase Order not found', HTTP_CODE[:NOT_FOUND]) unless purchase_order.present?

          memorandum = Memorandum.find_by(id: params[:memorandum_id])
          error!('memorandum not found', HTTP_CODE[:NOT_FOUND]) unless memorandum.present?

          publisher = Publisher.find_by(id: params[:publisher_id])
          error!('publisher not found', HTTP_CODE[:NOT_FOUND]) unless publisher.present?

          memorandum_publisher = MemorandumPublisher.find_by(memorandum_id: memorandum.id, publisher_id: publisher.id)

          error!('invalid memorandum or publisher', HTTP_CODE[:NOT_FOUND]) if memorandum_publisher.nil?

          error!('Purchase Order Status Not Found', HTTP_CODE[:NOT_FOUND]) unless purchase_order_status.present?
          purchase_order.update!(declared(params).merge(updated_by_id: @current_staff.id, memorandum_publisher:).except(:po_line_item_params))

          authorize purchase_order, :update?
          line_item_params = params[:po_line_item_params]
          line_item_params.each do |line_item|
            publisher_biblio = memorandum_publisher.publisher_biblios.find_by(id: line_item['publisher_biblio_id'])
            unless publisher_biblio.present?
              error!("Publisher Biblio not found under the memorandum_publisher : #{memorandum_publisher.id}", HTTP_CODE[:NOT_FOUND])
            end

            error!('quantity should be greater than 0') unless (line_item['quantity']).positive?
            error!('price should be greater than 0') unless (line_item['price']).positive?
            quantity = line_item['quantity']
            price = line_item['price']

            po_line_item = purchase_order.po_line_items.new(publisher_biblio:,
                                                            quantity:,
                                                            price:,
                                                            sub_total: purchase_order.sub_total_calculation(price, quantity),
                                                            bar_code: publisher_biblio.isbn)
            po_line_item.save!
          end
          Admin::Entities::PurchaseOrderDetails.represent(purchase_order) if purchase_order.save!
        end

        desc 'Purchase Order update status'

        params do
          use :purchase_order_status_update_params
        end

        patch 'status_update' do
          purchase_order = PurchaseOrder.not_deleted.find_by(id: params[:id])
          error!('Not found', HTTP_CODE[:NOT_FOUND]) unless purchase_order.present?

          validated_status = Admin::PoStatusValidation.call(purchase_order:, status: params[:status])
          error!(validated_status.error.to_s, HTTP_CODE[:NOT_ACCEPTABLE]) unless validated_status.success?
          authorize purchase_order, :update?
          purchase_order.update!(purchase_order_status_id: PurchaseOrderStatus.get_status(params[:status]).id)
          { message: 'status changed successfully', status: HTTP_CODE[:OK] }
        end

        desc 'Purchase Order delete'

        delete do
          purchase_order = PurchaseOrder.not_deleted.find_by(id: params[:id])
          error!('Not found', HTTP_CODE[:NOT_FOUND]) unless purchase_order.present?

          authorize purchase_order, :delete?
          purchase_order.update!(deleted_at: true)
          status HTTP_CODE[:OK]
        end

        desc 'purchase order received'
        params do
          use :purchase_order_received_params
        end

        put 'received' do
          purchase_order = PurchaseOrder.not_deleted.find_by(id: params[:id])
          error!('Not found', HTTP_CODE[:NOT_FOUND]) unless purchase_order.present?

          if purchase_order.purchase_order_status.received?
            error!('Status is received, no further changes is possible', HTTP_CODE[:BAD_REQUEST])
          end

          unless purchase_order.purchase_order_status.sent? || purchase_order.purchase_order_status.partially_received?
            error!('Can\'t update to received, please send it first', HTTP_CODE[:BAD_REQUEST])
          end
          goods_receipts = []
          authorize purchase_order, :po_received?
          error!('already received', HTTP_CODE[:BAD_REQUEST]) if purchase_order.purchase_order_status.received?
          purchase_order_status = true
          params[:po_line_item_params].each do |line_item_param|
            line_item = purchase_order.po_line_items.find_by(id: line_item_param[:po_line_item_id])
            error!('Po line item not found', HTTP_CODE[:NOT_FOUND]) unless line_item.present?
            error!('Receive Quantity Should Not Be Zero.', HTTP_CODE[:FORBIDDEN]) if line_item_param[:quantity] <= 0

            if line_item.quantity < line_item_param[:quantity]
              error!('Receive Quantity Should Not Be Getter Then Order Quantity.', HTTP_CODE[:FORBIDDEN])
            end

            if (line_item.quantity - line_item.received_quantity) < line_item_param[:quantity]
              error!('Do Not Have This Many Items To Receive.', HTTP_CODE[:FORBIDDEN])
            end
            gr_param = {
              po_line_item: line_item,
              purchase_order:,
              publisher_biblio: line_item.publisher_biblio,
              publisher: purchase_order.publisher,
              memorandum_publisher: purchase_order.memorandum_publisher,
              quantity: line_item_param[:quantity],
              price: line_item.price,
              sub_total: line_item.price * line_item_param[:quantity],
              purchase_code: line_item.purchase_code,
              bar_code: line_item.bar_code,
              updated_by: @current_staff
            }
            goods_receipts << GoodsReceipt.create!(gr_param)

            line_item.received_quantity = line_item.received_quantity
            line_item.save
          end
          purchase_order.po_line_items.each do |line_item|
            purchase_order_status = false unless line_item.received_quantity == line_item.quantity
          end

          if purchase_order_status
            purchase_order.purchase_order_status = PurchaseOrderStatus.get_status(:received)
            purchase_order.save
          end
          Admin::Entities::GoodsReceipts.represent(goods_receipts)
        end
      end
    end
  end
end
