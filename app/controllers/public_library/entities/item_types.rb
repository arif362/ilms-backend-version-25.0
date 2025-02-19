module PublicLibrary
  module Entities
    class ItemTypes < Grape::Entity
      expose :id
      expose :name
      expose :description, if: ->(_, options) { options[:details].present? }
    end
  end
end
