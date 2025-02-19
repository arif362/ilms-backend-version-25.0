# frozen_string_literal: true

module Admin
  module Entities
    class Complains < Grape::Entity
      expose :id
      expose :complain_type
      expose :user
      expose :creation
      expose :action_type
      expose :closed_or_resolved_at
      expose :closed_or_resolved_by_staff_id



      def user
        return 'Guest' unless object.user_id.present?

        {
          id: object.user.id,
          name: object.user.full_name
        }
      end

      def creation
        {
          date: object.created_at.to_date,
          time: object.created_at.strftime('%H:%M')
        }
      end
    end
  end
end
