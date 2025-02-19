module Admin
  module QueryParams
    module EBookParams
      extend ::Grape::API::Helpers

      params :e_book_create_params do
        requires :title, type: String, allow_blank: false
        requires :book_url, type: String, allow_blank: false
        optional :author, type: String
        optional :author_url, type: String
        optional :year, type: Integer
        optional :publisher, type: String
        optional :is_published, type: Boolean
      end

      params :e_book_update_params do
        requires :title, type: String, allow_blank: false
        requires :book_url, type: String, allow_blank: false
        optional :author, type: String
        optional :author_url, type: String
        optional :year, type: Integer
        optional :publisher, type: String
        optional :is_published, type: Boolean
      end

    end
  end
end
