class AddSingleColumnToBiblioItems < ActiveRecord::Migration[7.0]
  def change
    add_column :biblio_items, :item_collection_type, :integer
  end
end
