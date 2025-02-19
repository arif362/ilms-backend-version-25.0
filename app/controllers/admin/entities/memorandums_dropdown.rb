# frozen_string_literal: true

module Admin
  module Entities
    class MemorandumsDropdown < Grape::Entity
      expose :id
      expose :memorandum_no
    end
  end
end
