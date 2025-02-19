# frozen_string_literal: true

module Admin
  class LibraryTransferOrders < Admin::Base
    resources :library_transfer_orders do

      desc 'library transfer request list'
      params do
        use :pagination, per_page: 25
        optional :order_type, type: String, values: LibraryTransferOrder.order_types.keys
        optional :sender_library_id, type: Integer, allow_blank: false
        optional :receiver_library_id, type: Integer, allow_blank: false
        optional :return_start_date, type: DateTime, allow_blank: false
        optional :return_end_date, type: DateTime, allow_blank: false
        optional :start_date, type: DateTime, allow_blank: false
        optional :end_time, type: DateTime, allow_blank: false
        optional :biblio_title, type: String, allow_blank: false
      end
      get do
        library_transfer_orders = if params[:biblio_title].present?
                                    LibraryTransferOrder.joins(:biblio).where(
                                      'lower(biblios.title) like :search_term', search_term: "%#{params[:biblio_title].downcase}%").includes(:biblio)
                                  else
                                    LibraryTransferOrder.includes(:biblio)
                                  end

        if params[:order_type].present?
          library_transfer_orders = library_transfer_orders.send(params[:order_type].to_sym)
        end
        if params[:sender_library_id].present?
          library = Library.find_by(id: params[:sender_library_id])
          error!('Sender library not found', HTTP_CODE[:NOT_FOUND]) unless library.present?
          library_transfer_orders = library_transfer_orders.where(sender_library: library)
        end

        if params[:receiver_library_id].present?
          library = Library.find_by(id: params[:receiver_library_id])
          error!('Receiver library not found', HTTP_CODE[:NOT_FOUND]) unless library.present?
          library_transfer_orders = library_transfer_orders.where(receiver_library: library)
        end

        if params[:start_date].present? && params[:end_date].present?
          date_range = params[:start_date].to_date.beginning_of_day..params[:end_date].to_date.end_of_day
          library_transfer_orders = library_transfer_orders.where(created_at: date_range)
        end

        if params[:return_start_date].present? && params[:return_end_date].present?
          date_range = params[:return_start_date].to_date.beginning_of_day..params[:return_end_date].to_date.end_of_day
          library_transfer_orders = library_transfer_orders.where(return_at: date_range)
        end

        Admin::Entities::LibraryTransferOrders.represent(paginate(library_transfer_orders.order(id: :desc)))
      end

      route_param :id do
        get do
          library_transfer_order = LibraryTransferOrder.find_by(id: params[:id])
          Admin::Entities::LibraryTransferOrders.represent(library_transfer_order)
        end
      end
    end
  end
end
