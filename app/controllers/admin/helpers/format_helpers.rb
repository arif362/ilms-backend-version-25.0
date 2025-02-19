# frozen_string_literal: true

module Admin
  module Helpers
    module FormatHelpers
      extend Grape::API::Helpers

      # Helper method to check if the time is in 24-hour format
      def valid_time_format?(time_str)
        time_regex = /\A([01]\d|2[0-3]):[0-5]\d\z/
        !!(time_str =~ time_regex)
      end
    end
  end
end
