module PublicLibrary
  module Entities
    class Notifications < Grape::Entity
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
        locale == :en ? object.message : object.message_bn
      end

      def title
        locale == :en ? object.title : object.bn_title
      end

      def locale
        options[:locale]
      end
    end
  end
end