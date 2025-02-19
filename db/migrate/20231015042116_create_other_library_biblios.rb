class CreateOtherLibraryBiblios < ActiveRecord::Migration[7.0]
  def change
    create_table :other_library_biblios do |t|
      t.bigint :permanent_library_id
      t.bigint :current_library_id
      t.bigint :biblio_item_id
      t.bigint :biblio_id
      t.references :trackable, polymorphic: true
      t.integer :status, default: 0
      t.timestamps
    end
  end
end
