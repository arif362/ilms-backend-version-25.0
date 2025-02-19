module Admin
  module Entities
    class Roles < Grape::Entity
      expose :id
      expose :title
      expose :is_active
      expose :created_at
      expose :is_deleted
      expose :permission_codes, if: ->(_, options) { options[:all].present? }
      expose :staffs

      def staffs
        object.staffs.map(&:name)
      end
    end
  end
end
