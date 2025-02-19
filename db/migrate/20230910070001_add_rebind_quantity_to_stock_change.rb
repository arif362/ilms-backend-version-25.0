class AddRebindQuantityToStockChange < ActiveRecord::Migration[7.0]
  def change
    add_column :stock_changes, :rebind_biblio_quantity, :integer, default: 0
    add_column :stock_changes, :rebind_biblio_quantity_change, :integer, default: 0
  end
end
