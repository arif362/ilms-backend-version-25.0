class CreateTransferOrderStatusChanges < ActiveRecord::Migration[7.0]
  def change
    create_table :transfer_order_status_changes do |t|
      t.bigint :library_transfer_order_id, null: false
      t.integer :transfer_order_status_id, null: false
      t.integer :changed_by_id
      t.string :changed_by_type
      t.timestamps
    end
  end
end
