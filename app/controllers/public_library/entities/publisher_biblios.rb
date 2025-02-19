# frozen_string_literal: true

module PublicLibrary
  module Entities
    class PublisherBiblios < Grape::Entity

      expose :id
      expose :title
      expose :author_name
      expose :publication_date
      expose :isbn
    end
  end
end
