module PublicLibrary
  module Entities
    class BiblioLibraries < Grape::Entity
      expose :available_quantity
      expose :booked_quantity
      expose :borrowed_quantity
      expose :in_transit_quantity
      expose :not_for_borrow_quantity
      expose :lost_quantity
      expose :damaged_quantity
    end
  end
end