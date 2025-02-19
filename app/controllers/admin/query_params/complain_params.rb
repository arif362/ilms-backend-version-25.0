# frozen_string_literal: true

module Admin
  module QueryParams
    module ComplainParams
      extend ::Grape::API::Helpers

      params :complain_update_params do
        requires :reply, type: String
        requires :action_type, type: String, values: %w[pending less_severe severe very_severe]
        requires :send_notification, type: Boolean
        requires :send_email, type: Boolean
      end
    end
  end
end
