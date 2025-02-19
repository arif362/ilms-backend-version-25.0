class AddColumnLocationToBiblioLibraryLocations < ActiveRecord::Migration[7.0]
  def change
    add_column :biblio_library_locations, :library_location_id, :integer
    add_column :biblio_library_locations, :biblio_id, :integer
  end
end
