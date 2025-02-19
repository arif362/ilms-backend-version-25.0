class AddRemainingColumnsToBiblioItems < ActiveRecord::Migration[7.0]
  def change
    add_column :biblio_items, :price, :decimal, precision: 10, scale: 4, default: 0
    rename_column :biblio_items, :damage_biblio_status_id, :biblio_status_id
    remove_column :biblio_items, :lost_biblio_status_id
    add_reference :biblio_items, :item_type
  end
end
