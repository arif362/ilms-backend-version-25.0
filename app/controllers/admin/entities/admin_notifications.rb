module Admin
  module Entities
    class AdminNotifications < Grape::Entity
      expose :id
      expose :notificationable_id
      expose :notificationable_type
      expose :notifiable_id
      expose :notifiable_type
      expose :message
      expose :title
      expose :is_read
      expose :created_at

      def message
        object.message
      end

      def title
        object.title
      end
    end
  end
end
