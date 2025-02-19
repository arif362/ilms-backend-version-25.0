class AddColumnBiblioItemToStockChanges < ActiveRecord::Migration[7.0]
  def change
    add_column :stock_changes, :biblio_item_id, :bigint
  end
end
