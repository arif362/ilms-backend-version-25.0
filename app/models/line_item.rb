class LineItem < ApplicationRecord
  belongs_to :order
  belongs_to :biblio
  belongs_to :biblio_item, optional: true

  # after_create :update_availability
  # before_update :set_on_desk_quantity

  private

  def update_availability
    update_quantity(:available_quantity, :booked_quantity, 'order_placed')
    # biblio_library = biblio_item.biblio.biblio_libraries.find_by(library_id: biblio_item.library_id)
    # biblio_library.save_stock_change('order_placed', 1, order,
    #                                  'available_quantity_change', 'booked_quantity_change')
  end

  def set_on_desk_quantity
    return unless biblio_item_id_changed? && biblio_item_id_was.nil?
    # biblio_library.biblio_library_locations.first.decrement_quantity
    update_quantity(:booked_quantity, :on_desk_quantity, 'biblio_item_assign_by_library', true, 'decrease')
    # biblio_library = biblio_item.biblio.biblio_libraries.find_by(library_id: biblio_item.library_id)
    # biblio_library.save_stock_change('order_placed', 1, order,
    #                                  'available_quantity_change', 'booked_quantity_change')

  end

  def update_quantity(decrement_field, increment_field, stock_change_transaction_type, change_location_stock = false, change_location_stock_type = nil)
    biblio_library = biblio.biblio_libraries.find_by(library_id: order.library_id)
    biblio_library.decrement(decrement_field)
    biblio_library.increment(increment_field)
    biblio_library.save!

    if change_location_stock && biblio_library.biblio_library_locations.present?
      if change_location_stock_type == 'increase'
        biblio_library.biblio_library_locations.first.increment_quantity
      elsif change_location_stock_type == 'decrease'
        biblio_library.biblio_library_locations.first.decrement_quantity
      end
    end
    biblio_library.save_stock_change(stock_change_transaction_type, 1, order,
                                     'available_quantity_change', 'booked_quantity_change', biblio_item_id)
  end
end
