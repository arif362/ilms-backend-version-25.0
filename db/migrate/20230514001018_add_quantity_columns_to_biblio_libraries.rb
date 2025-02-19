class AddQuantityColumnsToBiblioLibraries < ActiveRecord::Migration[7.0]
  def change
    add_column :biblio_libraries, :on_desk_quantity, :integer, null: false, default: 0
    add_column :biblio_libraries, :return_on_desk_quantity, :integer, null: false, default: 0
    add_column :biblio_libraries, :cancelled_on_desk_quantity, :integer, null: false, default: 0
    add_column :biblio_libraries, :pl3_quantity, :integer, null: false, default: 0
    add_column :biblio_libraries, :return_3pl_quantity, :integer, null: false, default: 0
    add_column :biblio_libraries, :cancelled_3pl_quantity, :integer, null: false, default: 0
  end
end
