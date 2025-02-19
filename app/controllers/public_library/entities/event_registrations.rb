# frozen_string_literal: true

module PublicLibrary
  module Entities
    class EventRegistrations < Grape::Entity
      expose :name
      expose :phone
      expose :email
      expose :address
      expose :identity_type
      expose :identity_number
      expose :father_name
      expose :mother_name
      expose :profession
      expose :competition_name
      expose :participate_group
      expose :membership_no
      expose :library, using: PublicLibrary::Entities::LibraryList

      def membership_no
        options[:current_user]&.member&.unique_id || ''
      end

      def identity_type
        object.identity_type == 'not_applicable' ? nil : object.identity_type
      end
    end
  end
end
