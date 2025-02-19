# frozen_string_literal: true

# Pundit authorization helpers in API
module Admin::Helpers
  module AuthorizationHelpers
    def self.included(mod)
      # mod.after { verify_authorized }
      mod.helpers Pundit::Authorization
    end
  end
end
