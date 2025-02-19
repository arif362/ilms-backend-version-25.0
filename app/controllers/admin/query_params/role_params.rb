# frozen_string_literal: true

module Admin
  module QueryParams
    module RoleParams
      extend ::Grape::API::Helpers
      params :role_create_params do
        requires :title, type: String, allow_blank: false
        requires :permission_codes, type: Array[String], allow_blank: true#, values: Role::PERMISSION_GROUP.values.map(&:values).flatten.uniq
      end

      params :role_update_params do
        requires :title, type: String, allow_blank: false
        requires :permission_codes, type: Array[String], allow_blank: true#, values: Role::PERMISSION_GROUP.values.map(&:values).flatten.uniq
      end
    end
  end
end
