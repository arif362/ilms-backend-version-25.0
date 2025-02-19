# frozen_string_literal: true

module PublicLibrary
  module Entities
    class AccountDeletionRequest < Grape::Entity
      expose :id
      expose :user_id
      expose :status
    end
  end
end
