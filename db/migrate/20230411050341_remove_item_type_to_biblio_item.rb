class RemoveItemTypeToBiblioItem < ActiveRecord::Migration[7.0]
  def change
    remove_column :biblio_items, :item_type_id, :integer
  end
end
