module Admin
  module Entities
    class RoleDropdown < Grape::Entity
      expose :id
      expose :title
    end
  end
end
