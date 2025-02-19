module PublicLibrary
  module Entities
    class Ebooks < Grape::Entity
      expose :id
      expose :title
      expose :book_url
      expose :author
      expose :author_url
      expose :is_published
      expose :year
      expose :publisher
    end
  end
end
