# frozen_string_literal: true

module PublicLibrary
  class BiblioAuthors < PublicLibrary::Base
    resources :biblio_authors do
      desc 'author dropdown list'
      params do
        optional :search_term, type: String, regexp: { value: /^.{3,}$/,
                                                       message: 'must be minimum three characters long' }
      end
      route_setting :authentication, optional: true
      get 'dropdown' do
        authors = Author.not_deleted.order(id: :desc)
        if params[:search_term].present?
          authors = authors.where('lower(first_name) like :search_term
                                                  or lower(bn_first_name) like :search_term',
                                                  search_term: "#{params[:search_term].downcase}%")
        end
        PublicLibrary::Entities::Authors.represent(authors, locale: @locale)
      end
    end
  end
end
