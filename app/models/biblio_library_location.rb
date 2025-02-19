class BiblioLibraryLocation < ApplicationRecord
  belongs_to :biblio
  belongs_to :biblio_library
  belongs_to :library_location

  def increment_quantity
    update(quantity: quantity + 1)
  end

  def decrement_quantity
    update(quantity: quantity - 1)
  end
end
