# frozen_string_literal: true

module Lms
  module Entities
    class EventRegistrationStatus < Grape::Entity
      include Lms::Helpers::ImageHelpers

      expose :id
      expose :name
      expose :email
      expose :is_winner
      expose :winner_position
      expose :event
      expose :user
      expose :library

      def event
        object.event.as_json(only: %i[id title bn_title])
      end

      def user
        object.user.as_json(only: %i[id full_name email])
      end

      def library
        object.library.as_json(only: %i[id name bn_name])
      end

      def winner_position
        if object.winner_position.nil?
          'Not Listed'
        else
          object.winner_position
        end
      end
    end
  end
end
