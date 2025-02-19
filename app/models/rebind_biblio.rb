# frozen_string_literal: true

class RebindBiblio < ApplicationRecord
  belongs_to :biblio
  belongs_to :biblio_item
  belongs_to :library

  enum status: { pending: 0, in_progress: 1, completed: 3 }

  after_create :decrement_availability, if: :pending?
  after_update :increment_availability, if: :completed?

  private

  def decrement_availability
    # update_biblio_library_location('decrement')
    biblio_library.decrement!(:available_quantity)
    biblio_library.increment!(:rebind_biblio_quantity)

    biblio_library.save_stock_change('rebind_biblio_pending', 1, self, 'available_quantity_change', 'rebind_biblio_quantity_change')
  end

  def increment_availability
    update_biblio_library_location('increment')
    biblio_library.increment!(:available_quantity)
    biblio_library.decrement!(:rebind_biblio_quantity)

    biblio_library.save_stock_change('rebind_biblio_completed', 1, self, 'rebind_biblio_quantity_change', 'available_quantity_change')
  end

  def update_biblio_library_location(update_type)
    shelving_library_location = biblio_item.shelving_library_location
    biblio_library_location = biblio_library.biblio_library_locations.find_by(library_location_id: shelving_library_location.id)
    biblio_library_location.send("#{update_type}_quantity")
  end

  def biblio_library
    biblio.biblio_libraries.find_by(library_id: library.id)
  end
end
