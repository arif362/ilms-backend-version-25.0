# frozen_string_literal: true

module NotificationManagement
    class CreateBatchNotification
      include Interactor

      delegate :notificationable, :message, :message_bn, :permission, :roles, to: :context

      def call
        create_notifications(permission)
      end

      private

      def identify_roles(permission)
        roles = []
        Role.all.each do |role|
          roles << role.id if role.permission_codes.include?(permission)
        end
        roles
      end

      def create_notifications(permission)
        roles = identify_roles(permission)
        Staff.where(role_id: roles).each do |staff|
          Notification.create(notifiable: staff,
                              notificationable:,
                              message:,
                              message_bn:)
        end
      end
    end
end
