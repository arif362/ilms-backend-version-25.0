class BiblioLibrary < ApplicationRecord
  belongs_to :library
  belongs_to :biblio
  has_many :stock_changes, dependent: :restrict_with_exception
  has_many :biblio_library_locations, dependent: :restrict_with_exception
  has_many :library_locations, through: :biblio_library_locations

  def save_stock_change(transaction_type, quantity, stock_changeable, decrement_field, increment_field)
    stock_change = stock_changes.new(
      available_quantity:,
      booked_quantity:,
      borrowed_quantity:,
      three_pl_quantity:,
      not_for_borrow_quantity:,
      lost_quantity:,
      damaged_quantity:,
      on_desk_quantity:,
      return_on_desk_quantity:,
      cancelled_on_desk_quantity:,
      return_3pl_quantity:,
      cancelled_3pl_quantity:,
      in_library_quantity:,
      return_in_library_quantity:,
      rebind_biblio_quantity:,
      library_id:,
      biblio_id:,
      stock_transaction_type: transaction_type,
      quantity: quantity,
      stock_changeable: stock_changeable,
    )

    stock_change[increment_field] = quantity if increment_field
    stock_change[decrement_field] = -quantity if decrement_field
    stock_change.save!
  end
end
