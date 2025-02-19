class AddCirculationIdToStockChanges < ActiveRecord::Migration[7.0]
  def change
    add_column :stock_changes, :circulation_id, :integer
  end
end
