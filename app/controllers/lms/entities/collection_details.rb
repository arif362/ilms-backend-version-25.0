module Lms
  module Entities
    class CollectionDetails < Grape::Entity
      expose :id
      expose :title
      expose :created_by
      expose :updated_by

      def created_by
        staff = Staff.find_by(id: object&.created_by_id)
        {
          id: staff&.id || nil,
          title: staff&.name || ''
        }
      end

      def updated_by
        staff = Staff.find_by(id: object&.updated_by_id)
        {
          id: staff&.id || nil,
          title: staff&.name || ''
        }
      end

    end
  end
end

