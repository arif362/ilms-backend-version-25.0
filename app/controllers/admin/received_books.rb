# frozen_string_literal: true

module Admin
  class ReceivedBooks < Admin::Base
    include Admin::Helpers::AuthorizationHelpers
    resources :received_books do

      desc 'List of All Received Books'
      get do
        received_books = GoodsReceipt.unique_by_po_line_item_id
        authorize received_books, :read?
        Admin::Entities::ReceivedBooks.represent(received_books)
      end

      desc 'receved book dropdown'
      params do
        optional :title, type: String, allow_blank: false
      end
      get 'search' do
        publisher_biblios = PublisherBiblio.all
        if params[:title].present?
          publisher_biblios = PublisherBiblio.where('lower(title) like :search_term',
                                                    search_term: "%#{params[:title].downcase}%")
        end
        publisher_biblios.as_json(only: %i[id title publisher_phone])
      end


      desc 'Send Department Biblio Item to Library'
      params do
        requires :library_id, type: Integer, allow_blank: false
        optional :publisher_biblios, allow_blank: false, type: Array do
          requires :id, allow_blank: false, type: Integer
          requires :accession_numbers, allow_blank: false, type: Array[String]
        end
      end
      patch :send_to_library do

        library = Library.active.find_by(id: params[:library_id])
        error!('Library not found', HTTP_CODE[:NOT_FOUND]) if library.nil?

        updated_department_biblio_items = []
        distribution = {}
        ActiveRecord::Base.transaction do
          distribution = Distribution.create(status: "pending", library_id: params[:library_id])
          params[:publisher_biblios].each do |biblios|
            biblios[:accession_numbers] = biblios[:accession_numbers].uniq
            department_biblio_items = DepartmentBiblioItem.where(central_accession_no: biblios[:accession_numbers]).where(publisher_biblio_id: biblios[:id], library_id: nil)
            error!('Item not found in department inventory', HTTP_CODE[:NOT_FOUND]) if department_biblio_items.nil?

            missing_accession = biblios[:accession_numbers] - department_biblio_items.pluck(:central_accession_no)
            if missing_accession.present?
              error!("Accession Not Found #{missing_accession.join(', ')}", HTTP_CODE[:NOT_FOUND])
            end
            authorize department_biblio_items, :update?

            department_biblio_items.each do |department_biblio_item|
              flag = department_biblio_item.update!(library:,
                                                    department_biblio_item_status: DepartmentBiblioItemStatus.get_status(:sent),
                                                    updated_by: @current_staff, distribution_id: distribution.id)
              updated_department_biblio_items << department_biblio_item if flag.present?
            end
          end
        end
        if distribution.update_columns(item_count: updated_department_biblio_items.count)
          Admin::DistributionSentToLibraryJob.perform_later(distribution, 'created')
        end
        updated_department_biblio_items
      end



      route_param :id do
        desc 'details of a received books item'

        get do
          received_book = GoodsReceipt.find_by(id: params[:id])
          error!('received books not found') if received_book.nil?

          authorize received_book, :read?
          Admin::Entities::ReceivedBooks.represent(received_book)
        end


        desc 'publisher biblio accession list'

        get 'accession_list' do
          accession_list = DepartmentBiblioItem.where.not(central_accession_no: nil).where(publisher_biblio_id: params[:id], library_id: nil).pluck(:central_accession_no)

          accession_list

        end


        desc 'Add Accession Number to Department Biblio Item'
        params do
          requires :quantity, type: Integer, allow_blank: false
        end
        patch 'add_accession_number' do
          line_item = GoodsReceipt.find_by(id: params[:id])
          error!('Received books not found', HTTP_CODE[:NOT_FOUND]) if line_item.nil?

          if line_item.received_quantity < params[:quantity].to_i
            error!('Quantity is greater than received quantity', HTTP_CODE[:BAD_REQUEST])
          end

          department_biblio_item = DepartmentBiblioItem.where(publisher_biblio: line_item.publisher_biblio,
                                                              central_accession_no: nil).first

          authorize department_biblio_item, :update?
          updated_department_biblio_item = []
          (1..params[:quantity].to_i).each do
            id = department_biblio_item.id.to_i
            flag =  department_biblio_item.update!(central_accession_no: department_biblio_item.central_accession_number)
            updated_department_biblio_item << department_biblio_item if flag
            department_biblio_item = DepartmentBiblioItem.find_by(id: id + 1)
          end
          updated_department_biblio_item
        end

      end
    end
  end
end
