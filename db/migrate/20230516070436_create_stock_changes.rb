class CreateStockChanges < ActiveRecord::Migration[7.0]
  def change
    create_table :stock_changes do |t|
      t.integer :stock_transaction_type, null: false
      t.integer :available_quantity, default: 0
      t.integer :booked_quantity, default: 0
      t.integer :borrowed_quantity, default: 0
      t.integer :three_pl_quantity, default: 0
      t.integer :not_for_borrow_quantity, default: 0
      t.integer :lost_quantity, default: 0
      t.integer :damaged_quantity, default: 0
      t.integer :on_desk_quantity, default: 0
      t.integer :return_on_desk_quantity, default: 0
      t.integer :cancelled_on_desk_quantity, default: 0
      t.integer :return_3pl_quantity, default: 0
      t.integer :cancelled_3pl_quantity, default: 0
      t.integer :in_library_quantity, default: 0
      t.integer :return_in_library_quantity, default: 0
      t.integer :available_quantity_change, default: 0
      t.integer :booked_quantity_change, default: 0
      t.integer :borrowed_quantity_change, default: 0
      t.integer :three_pl_quantity_change, default: 0
      t.integer :not_for_borrow_quantity_change, default: 0
      t.integer :lost_quantity_change, default: 0
      t.integer :damaged_quantity_change, default: 0
      t.integer :on_desk_quantity_change, default: 0
      t.integer :return_on_desk_quantity_change, default: 0
      t.integer :in_library_quantity_change, default: 0
      t.integer :return_in_library_quantity_change, default: 0
      t.integer :cancelled_on_desk_quantity_change, default: 0
      t.integer :return_3pl_quantity_change, default: 0
      t.integer :cancelled_3pl_quantity_change, default: 0
      t.integer :library_id
      t.integer :biblio_library_id
      t.integer :biblio_id
      t.integer :stock_changeable_id
      t.string :stock_changeable_type

      t.timestamps
    end
  end
end
