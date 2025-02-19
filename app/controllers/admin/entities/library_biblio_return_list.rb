# frozen_string_literal: true

module Admin
  module Entities
    class LibraryBiblioReturnList < Grape::Entity

      expose :id
      expose :name
      expose :code
      expose :returned_count

      def returned_count
        status_id = options[:circulation_status].id
        object.circulations.where(circulation_status_id: status_id).count
      end
    end
  end
end
