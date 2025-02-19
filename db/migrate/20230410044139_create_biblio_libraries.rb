class CreateBiblioLibraries < ActiveRecord::Migration[7.0]
  def change
    create_table :biblio_libraries do |t|
      t.integer :available_quantity, default: 0
      t.integer :booked_quantity, default: 0
      t.integer :borrowed_quantity, default: 0
      t.integer :in_transit_quantity, default: 0
      t.integer :not_for_borrow_quantity, default: 0
      t.integer :lost_quantity, default: 0
      t.integer :damaged_quantity, default: 0
      t.references :library
      t.references :biblio
      t.timestamps
    end
  end
end
