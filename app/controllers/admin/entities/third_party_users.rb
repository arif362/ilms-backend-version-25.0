module Admin
  module Entities
    class ThirdPartyUsers < Grape::Entity
      include Admin::Helpers::ImageHelpers

      expose :id
      expose :name
      expose :email
      expose :phone
      expose :company
      expose :service_type
      expose :is_active
    end
  end
end
