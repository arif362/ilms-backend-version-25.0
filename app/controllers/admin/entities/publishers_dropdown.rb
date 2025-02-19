module Admin
  module Entities
    class PublishersDropdown < Grape::Entity
      expose :id
      expose :publication_name
    end
  end
end
