module PublicLibrary
  class Ebooks < PublicLibrary::Base
    resources :ebooks do
      desc 'get e_books list'
      params do
        use :pagination, max_per_page: 25
        optional :search_term, type: String
      end

      route_setting :authentication, optional: true
      get do
        e_books = if params[:search_term].present?
                    paginate(EBook.published.where('lower(title) like :search_term or lower(author) like :search_term',
                                                   search_term: "%#{params[:search_term].downcase}%").order(id: :desc))
                  else
                    paginate(EBook.published.all.order(id: :desc))
                  end
        PublicLibrary::Entities::Ebooks.represent(e_books)
      end
    end
  end
end
