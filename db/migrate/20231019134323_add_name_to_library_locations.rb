class AddNameToLibraryLocations < ActiveRecord::Migration[7.0]
  def change
    add_column :library_locations, :name, :string
    add_column :library_locations, :type, :integer
  end
end
