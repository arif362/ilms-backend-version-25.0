class AddRebindQuantityToBiblioLibrary < ActiveRecord::Migration[7.0]
  def change
    add_column :biblio_libraries, :rebind_biblio_quantity, :integer, default: 0
  end
end
