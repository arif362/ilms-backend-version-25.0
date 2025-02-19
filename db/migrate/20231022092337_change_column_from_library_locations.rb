class ChangeColumnFromLibraryLocations < ActiveRecord::Migration[7.0]
  def change
    rename_column :library_locations, :type, :location_type
  end
end
