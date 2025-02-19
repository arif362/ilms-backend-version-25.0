# frozen_string_literal: true

module PublicLibrary
  class ReturnOrders < PublicLibrary::Base
    helpers PublicLibrary::QueryParams::ReturnOrderParams

    resources :return_orders do

      desc 'Return list of current user'

      params do
        use :pagination, per_page: 25
      end

      get do
        return_orders = @current_user.return_orders.includes(:return_items)
        PublicLibrary::Entities::ReturnOrder.represent(paginate(return_orders), locale: @locale,
                                                                                request_source: @request_source)
      end

      desc 'initiate return'
      params do
        use :return_create_params
      end
      post do
        return_status = ReturnStatus.get_status(ReturnStatus.status_keys[:initiated])
        library = Library.find_by(thana_id: params[:thana_id])
        member = @current_user.member
        if params[:address_type] == 'others'
          error!('Pick up division is required', HTTP_CODE[:BAD_REQUEST]) unless params[:division_id].present?
          error!('Pick up district is required', HTTP_CODE[:BAD_REQUEST]) unless params[:district_id].present?
          error!('Pick up thana is required', HTTP_CODE[:BAD_REQUEST]) unless params[:thana_id].present?
          error!('Recipient name is required', HTTP_CODE[:BAD_REQUEST]) unless params[:recipient_name].present?
          error!('Recipient phone is required', HTTP_CODE[:BAD_REQUEST]) unless params[:recipient_phone].present?
          error!('Delivery area is required', HTTP_CODE[:BAD_REQUEST]) unless params[:delivery_area].present?
          error!('Delivery area ID is required', HTTP_CODE[:BAD_REQUEST]) unless params[:delivery_area_id].present?
        elsif params[:address_type] == 'permanent'
          params[:division_id] = member.permanent_division_id
          params[:district_id] = member.permanent_district_id
          params[:thana_id] = member.permanent_thana_id
          params[:delivery_area_id] = @current_user.saved_addresses.permanent.last.delivery_area_id
          params[:delivery_area] = @current_user.saved_addresses.permanent.last.delivery_area
        else
          params[:division_id] = member.present_division_id
          params[:district_id] = member.present_district_id
          params[:thana_id] = member.present_thana_id
          params[:delivery_area_id] = @current_user.saved_addresses.present.last.delivery_area_id
          params[:delivery_area] = @current_user.saved_addresses.present.last.delivery_area
        end

        return_order = @current_user.return_orders.build(
          return_status_id: return_status.id,
          library_id: library.id,
          address_type: params[:address_type],
          address: params[:address],
          division_id: params[:division_id],
          district_id: params[:district_id],
          thana_id: params[:thana_id],
          return_type: :return_from_home,
          delivery_area: params[:delivery_area],
          delivery_area_id: params[:delivery_area_id],
          note: params[:note]
        )

        params[:circulation_ids].each do |item_id|
          circulation = Circulation.find_by_id(item_id)
          error!('Book not found in your circulation', HTTP_CODE[:NOT_FOUND]) unless circulation.present?

          if circulation.circulation_status != CirculationStatus.get_status(:borrowed)
            error!("#{circulation.biblio_item.biblio.title} not found in borrowed list", HTTP_CODE[:BAD_REQUEST])
          elsif ReturnItem.find_by(circulation_id: circulation.id).present?
            error!("Return already initiated for #{circulation.biblio_item.biblio.title}", HTTP_CODE[:BAD_REQUEST])
          end

          if circulation.returned_at.present?
            error!("#{circulation.biblio_item.biblio.title} already returned", HTTP_CODE[:BAD_REQUEST])
          end

          return_order.return_items.build(
            biblio_id: circulation.biblio_item.biblio_id,
            biblio_item_id: circulation.biblio_item_id,
            circulation_id: circulation.id
          )
        end

        if params[:save_address].present? && params[:address_type] == 'others'
          error!('Address title/name is required', HTTP_CODE[:BAD_REQUEST]) unless params[:address_name].present?
          error!('Delivery area name is required', HTTP_CODE[:BAD_REQUEST]) unless params[:delivery_area_id].present?
          error!('Delivery area id is required', HTTP_CODE[:BAD_REQUEST]) unless params[:delivery_area].present?
          SavedAddress.add_address(@current_user, params[:address_name], params[:address], params[:division_id],
                                   params[:district_id], params[:thana_id], params[:recipient_name], params[:recipient_phone], params[:delivery_area_id], params[:delivery_area])
        end


        if return_order.save!
          PublicLibrary::Entities::ReturnOrder.represent(return_order, locale: @locale,
                                                                       request_source: @request_source)
        end
      end
    end
  end
end
