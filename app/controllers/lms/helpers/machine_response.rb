# frozen_string_literal: true

module Lms::Helpers
  module MachineResponse
    extend Grape::API::Helpers

    def success_response(message, code, date = {})
      {
        "success": true,
        "message": message,
        "status_code": code,
        "data": date
      }
    end

    def failed_response(message, code, date = {})
      {
        "success": false,
        "message": message,
        "status_code": code,
        "data": date
      }
    end
  end
end
