# frozen_string_literal: true

module Lms
  module Entities
    class ReturnOrder < Grape::Entity
      include Lms::Helpers::ImageHelpers

      expose :id
      expose :library
      expose :return_status
      expose :user
      expose :delivery_type
      expose :address_type
      expose :address
      expose :division
      expose :district
      expose :thana
      expose :note
      expose :created_at
      expose :updated_at
      expose :total_fine

      def user
        object.user.as_json(only: %i[id full_name email phone dob gender])
      end

      def library
        object.library.as_json(only: %i[id name bn_name library_type address bn_address phone email district_id])
      end

      def return_status
        object.return_status.status_key
      end

      def division
        object.division.as_json(only: %i[id name bn_name])
      end

      def district
        object.district.as_json(only: %i[id name bn_name])
      end

      def thana
        object.thana.as_json(only: %i[id name bn_name])
      end

    end
  end
end
