class AddIsExistingItemToDepartmentBiblioItems < ActiveRecord::Migration[7.0]
  def change
    add_column :department_biblio_items, :is_existing_item, :boolean
  end
end
