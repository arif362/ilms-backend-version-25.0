class CreateBiblioLibraryLocations < ActiveRecord::Migration[7.0]
  def change
    create_table :biblio_library_locations do |t|
      t.references :biblio_library
      t.integer :quantity, default: 0
      t.timestamps
    end
  end
end
