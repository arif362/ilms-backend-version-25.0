class CreateRebindBiblios < ActiveRecord::Migration[7.0]
  def change
    create_table :rebind_biblios do |t|
      t.integer :biblio_id
      t.integer :library_id
      t.integer :biblio_item_id
      t.integer :status, default: 0
      t.integer :created_by_id
      t.integer :updated_by_id
      t.timestamps
    end
  end
end
