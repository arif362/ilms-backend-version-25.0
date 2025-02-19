# frozen_string_literal: true

module PublicLibrary
  module Entities
    class ExtendRequests < Grape::Entity

      expose :id
      expose :status
      expose :circulation

      def circulation
        PublicLibrary::Entities::Circulations.represent(object.circulation,
                                                        locale: options[:locale],
                                                        request_source: options[:request_source])
      end
    end
  end
end
