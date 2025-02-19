# frozen_string_literal: true

module PublicLibrary
  class BookTransferOrders < PublicLibrary::Base
    helpers PublicLibrary::QueryParams::BookTransferOrderParams
    resources :book_transfer_orders do
      desc 'Create paper book transfer request'
      params do
        use :book_transfer_order_create_params
      end
      post do
        biblio = Biblio.find_by(id: params[:biblio_id]) || Biblio.find_by(slug: params[:biblio_id])
        error!('Biblio not found', HTTP_CODE[:NOT_FOUND]) unless biblio.present?

        library = Library.find_by(id: params[:library_id])
        error!('library not found', HTTP_CODE[:NOT_FOUND]) unless library.present?

        exist_book_transfer_order = @current_user.book_transfer_orders.pending.find_by(biblio: biblio)
        error!('Transfer request already exist', HTTP_CODE[:NOT_ACCEPTABLE]) if exist_book_transfer_order.present?

        book_transfer_order = @current_user.book_transfer_orders.pending.create!(biblio_id: biblio.id, library_id: library.id)
        PublicLibrary::Entities::LibraryTransferOrderDetails.represent(book_transfer_order, locale: @locale)
      end

      desc 'current user paper book library transfer request list'
      params do
        use :pagination, per_page: 25
        optional :status, type: String, values: BookTransferOrder.statuses.keys
      end
      get do
        book_transfer_orders = @current_user.book_transfer_orders
        book_transfer_orders = book_transfer_orders.send(params[:status].to_sym) if params[:status].present?
        PublicLibrary::Entities::LibraryTransferOrder.represent(paginate(book_transfer_orders.order(id: :desc)),
                                                                locale: @locale,
                                                                current_user: @current_user)
      end

      route_param :id do
        get do
          book_transfer_order = @current_user.book_transfer_orders.find_by(id: params[:id])
          PublicLibrary::Entities::LibraryTransferOrderDetails.represent(book_transfer_order,
                                                                         locale: @locale,
                                                                         current_user: @current_user)

        end

        patch 'cancel' do
          book_transfer_order = @current_user.book_transfer_orders.find_by(id: params[:id])
          error!('Book transfer order request not found', HTTP_CODE[:NOT_FOUND]) unless book_transfer_order.present?
          unless book_transfer_order.pending?
            error!('Book transfer order request is not at cancellable state', HTTP_CODE[:NOT_ACCEPTABLE])
          end
          book_transfer_order.cancelled!
          PublicLibrary::Entities::LibraryTransferOrderDetails.represent(book_transfer_order, locale: @locale)
        end
      end
    end
  end
end
