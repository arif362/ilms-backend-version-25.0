class AddDeliveredToLibQtyToBiblioLibraries < ActiveRecord::Migration[7.0]
  def change
    add_column :biblio_libraries, :delivered_to_library_quantity, :integer, default: 0, null: false
  end
end
