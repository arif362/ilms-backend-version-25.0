class AddColumnInLibraryReturnInLibraryQuantityToBiblioLibraries < ActiveRecord::Migration[7.0]
  def change
    add_column :biblio_libraries, :in_library_quantity, :integer, default: 0
    add_column :biblio_libraries, :return_in_library_quantity, :integer, default: 0
  end
end
