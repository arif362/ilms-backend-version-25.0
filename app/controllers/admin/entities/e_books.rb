module Admin
  module Entities
    class EBooks < Grape::Entity
      expose :id
      expose :title
      expose :book_url
      expose :author
      expose :author_url
      expose :is_published
      expose :year
      expose :publisher
      expose :created_at
      expose :updated_at

    end
  end
end
