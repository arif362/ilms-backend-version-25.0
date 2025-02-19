class AddColumnQuantityToStockChanges < ActiveRecord::Migration[7.0]
  def change
    add_column :stock_changes, :quantity, :integer, default: 0
  end
end
