module Admin
  module Entities
    class IntlResearchGateways < Grape::Entity
      expose :id
      expose :name
      expose :url
      expose :is_deleted
      expose :is_published
      expose :created_at
      expose :updated_at

    end
  end
end
