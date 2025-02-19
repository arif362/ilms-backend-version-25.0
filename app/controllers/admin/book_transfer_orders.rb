# frozen_string_literal: true

module Admin
  class BookTransferOrders < Admin::Base
    resources :book_transfer_orders do

      desc 'book transfer request list'
      params do
        use :pagination, per_page: 25
        optional :status, type: String, values: BookTransferOrder.statuses.keys
        optional :library_id, type: Integer
      end
      get do
        book_transfer_orders = BookTransferOrder.all
        book_transfer_orders = book_transfer_orders.send(params[:status].to_sym) if params[:status].present?
        if params[:library_id].present?
          library = Library.find_by(id: params[:library_id])
          error!('Library not found', HTTP_CODE[:NOT_FOUND]) unless library.present?
          book_transfer_orders = library.book_transfer_orders
        end

        Admin::Entities::BookTransferOrder.represent(paginate(book_transfer_orders.order(id: :desc)))
      end

      route_param :id do
        get do
          book_transfer_order = BookTransferOrder.find_by(id: params[:id])
          Admin::Entities::BookTransferOrder.represent(book_transfer_order)

        end
      end
    end
  end
end
