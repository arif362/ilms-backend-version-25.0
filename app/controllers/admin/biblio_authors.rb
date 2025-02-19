module Admin
  class BiblioAuthors < Base
    include Admin::Helpers::AuthorizationHelpers

    resources :authors do

      desc 'get authors list'
      params do
        use :pagination, max_per_page: 25
        optional :search_term, type: String, allow_blank: false
      end
      get do
        authors = Author.not_deleted.all
        authorize authors, :read?
        authors = authors.where("first_name LIKE ?", "%#{params[:search_term]}%") if params[:search_term].present?
        Admin::Entities::Authors.represent(paginate(authors))
      end

      route_param :id do
        desc 'get author details'
        get do
          author = Author.not_deleted.find_by(id: params[:id])
          authorize author, :read?
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless author.present?
          Admin::Entities::Authors.represent(author)
        end
      end

    end
  end
end
