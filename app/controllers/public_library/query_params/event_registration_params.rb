# frozen_string_literal: true

module PublicLibrary
  module QueryParams
    module EventRegistrationParams
      extend ::Grape::API::Helpers
      params :event_registration_create_params do
        requires :library_code, type: String
        requires :competition_info, type: Array do
          requires :competition_name, type: String
          optional :participate_group, type: String, values: EventRegistration.participate_groups.keys
        end
        optional :registration_fields, type: Hash do
          optional :name, type: String
          optional :phone, type: String
          optional :identity_type, type: String, values: %w[nid birth_certificate]
          optional :identity_number, type: String
          optional :email, type: String
          optional :address, type: String
          optional :father_name, type: String
          optional :mother_name, type: String
          optional :profession, type: String
        end
      end
    end
  end
end
