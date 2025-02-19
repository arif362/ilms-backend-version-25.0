class RemoveItemTypeToBiblios < ActiveRecord::Migration[7.0]
  def change
    remove_column :biblios, :item_type_id, :integer
    drop_table :item_types
  end
end
