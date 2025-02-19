module Admin
  class Ebooks < Base
    include Admin::Helpers::AuthorizationHelpers
    helpers Admin::QueryParams::EBookParams

    resources :ebooks do

      desc 'get e_books list'
      params do
        use :pagination, max_per_page: 25
        optional :search_term, type: String
      end
      get do
        e_books = if params[:search_term].present?
                    paginate(EBook.where('lower(title) like :search_term or lower(author) like :search_term',
                                          search_term: "%#{params[:search_term].downcase}%").order(id: :desc))
                  else
                    paginate(EBook.all.order(id: :desc))
                  end
        authorize e_books, :read?
        Admin::Entities::EBooks.represent(e_books)
      end


      desc 'create e-book'
      params do
        use :e_book_create_params
      end
      post do
        e_book = EBook.create!(declared(params, include_missing: false)
                                                              .merge(created_by_id: @current_staff.id, updated_by_id: @current_staff.id))
        authorize e_book, :create?
        Admin::Entities::EBooks.represent(e_book)
      end

      desc 'upload as bulk e-book'
      params do
        requires :ebook_csv_file, type: File, allow_blank: false
      end
      post 'import' do
        e_book = EBook.new
        authorize e_book, :import?

        EBook.import_ebooks(params[:ebook_csv_file])
        status HTTP_CODE[:CREATED]
      end

      desc 'upload as bulk e-book'
      params do
        requires :ebook_ids, type: Array, allow_blank: false
      end
      delete 'bulk_delete' do
        e_books = EBook.where(id: params[:ebook_ids])
        authorize e_books, :delete_all?

        error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless e_books.present?

        e_books.delete_all
        status HTTP_CODE[:OK]
      end

      route_param :id do

        desc 'get e_book details'
        get do
          e_book = EBook.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless e_book.present?
          authorize e_book, :read?
          Admin::Entities::EBooks.represent(e_book)
        end

        desc 'update e_book'
        params do
          use :e_book_update_params
        end
        put do
          e_book = EBook.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless e_book.present?
          authorize e_book, :update?
          e_book.update!(declared(params, include_missing: false).merge(updated_by_id: @current_staff.id))
          Admin::Entities::EBooks.represent(e_book)
        end

        desc 'delete e-book'
        delete do
          e_book = EBook.find_by(id: params[:id])
          error!('Not found', HTTP_CODE[:NOT_FOUND]) unless  e_book.present?
          authorize e_book, :delete?
          e_book.destroy
          status HTTP_CODE[:OK]
        end
      end
    end
  end
end
