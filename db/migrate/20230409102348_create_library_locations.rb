class CreateLibraryLocations < ActiveRecord::Migration[7.0]
  def change
    create_table :library_locations do |t|
      t.string :name
      t.references :library

      t.timestamps
    end
  end
end
