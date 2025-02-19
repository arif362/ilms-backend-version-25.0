class AddBiblioItemIdToDepartmentBiblioItem < ActiveRecord::Migration[7.0]

  def change
    add_column :department_biblio_items, :biblio_item_id, :integer
  end
end
