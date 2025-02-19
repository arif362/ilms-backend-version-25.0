# frozen_string_literal: true

module PublicLibrary
  module Entities
    class CardStatuses < Grape::Entity
      expose :id
      expose :status_key
      expose :patron_status

      def patron_status
        options[:locale] == :en ? object.patron_status : object.bn_patron_status
      end
    end
  end
end
