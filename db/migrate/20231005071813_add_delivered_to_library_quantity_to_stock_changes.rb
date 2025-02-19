class AddDeliveredToLibraryQuantityToStockChanges < ActiveRecord::Migration[7.0]
  def change
    add_column :stock_changes, :delivered_to_library_quantity, :integer, default: 0
    add_column :stock_changes, :delivered_to_library_quantity_change, :integer, default: 0
  end
end
