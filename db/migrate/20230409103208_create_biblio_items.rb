class CreateBiblioItems < ActiveRecord::Migration[7.0]
  def change
    create_table :biblio_items do |t|
      t.string :barcode
      t.string :full_call_number
      t.string :note
      t.string :copy_number
      t.boolean :not_for_loan
      t.datetime :date_accessioned
      t.references :biblio
      t.integer :library_id
      t.integer :permanent_library_location_id
      t.integer :current_library_location_id
      t.integer :shelving_library_location_id
      t.integer :biblio_classification_id
      t.integer :damage_biblio_status_id
      t.integer :lost_biblio_status_id

      t.timestamps
    end
  end
end
