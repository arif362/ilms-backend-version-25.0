module PublicLibrary
  module Entities
    class BiblioEditions < Grape::Entity
      expose :id
      expose :title
      expose :description, if: ->(_, options) { options[:details].present? }
    end
  end
end
