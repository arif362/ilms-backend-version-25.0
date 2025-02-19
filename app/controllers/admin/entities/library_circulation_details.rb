# frozen_string_literal: true

module Admin
  module Entities
    class LibraryCirculationDetails < Grape::Entity
      expose :id
      expose :name
      expose :code
      expose :circulations do |instance|
        status_key = if options[:returned]
                       'returned'
                     else
                       'borrowed'
                     end
        circulation_status = CirculationStatus.get_status(status_key.to_sym)
        Admin::Entities::CirculationDetails.represent(instance.circulations
                                                              .where(circulation_status_id: circulation_status.id))
      end
    end
  end
end
