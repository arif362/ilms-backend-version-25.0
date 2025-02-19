class RenameColumnInLibraryLocation < ActiveRecord::Migration[7.0]
  def change
    rename_column :library_locations, :name, :code
  end
end
