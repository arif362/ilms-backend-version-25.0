# frozen_string_literal: true

module Admin
  module Entities
    class AuditLogDetails < Grape::Entity
      expose :id
      expose :auditable_id
      expose :auditable_type
      expose :user_type
      expose :online_user
      expose :staff
      expose :third_party
      expose :action
      expose :audited_changes
      expose :version
      expose :created_at

      def online_user
        return {} unless object.user_type == 'User'

        user = object.user
        {
          id: user.id,
          name: user.full_name,
          email: user.email,
          phone: user.phone,
          is_member: user.member&.present?
        }

      end

      def third_party
        return {} unless object.user_type == 'ThirdPartyUser'

        third_party = object.user
        {
          id: third_party.id,
          name: third_party.name,
          email: third_party.email,
          phone: third_party.phone,
          company: third_party.company
        }
      end

      def staff
        return {} unless object.user_type == 'Staff'

        staff = object.user
        {
          id: staff.id,
          name: staff.name,
          email: staff.email,
          phone: staff.phone,
          staff_type: staff.staff_type,
          library: staff.library.as_json(only: %i[id code name]),
          designation: staff.designation.as_json(only: %i[id title])
        }
      end
    end
  end
end
