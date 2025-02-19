class CreateLostDamagedBiblios < ActiveRecord::Migration[7.0]
  def change
    create_table :lost_damaged_biblios do |t|
      t.integer :member_id
      t.integer :library_id, null: false
      t.integer :biblio_item_id, null: false
      t.integer :updated_by, null: false
      t.integer :circulation_id
      t.integer :request_type, default: 0
      t.integer :status, default: 0
      t.integer :biblio_id, null: false

      t.timestamps
    end
  end
end
