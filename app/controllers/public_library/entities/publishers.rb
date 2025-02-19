# frozen_string_literal: true

module PublicLibrary
  module Entities
    class Publishers < Grape::Entity
      expose :id
      expose :track_no
      expose :name
      expose :publication_name
      expose :author_name
      expose :address
      expose :organization_phone
      expose :organization_email
      expose :publisher_phone

      def publisher_phone
        object&.user&.phone
      end
    end
  end
end
