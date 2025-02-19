# frozen_string_literal: true

module PublicLibrary
  module Entities
    class Authors < Grape::Entity
      expose :id
      expose :full_name
      expose :title, if: ->(_, options) { options[:details].present? }
      expose :dob, if: ->(_, options) { options[:details].present? }


      def full_name
        locale == :en ? object&.full_name : object&.bn_full_name
      end

      def locale
        options[:locale]
      end
    end
  end
end
