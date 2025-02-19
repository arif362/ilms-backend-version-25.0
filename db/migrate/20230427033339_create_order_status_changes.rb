class CreateOrderStatusChanges < ActiveRecord::Migration[7.0]
  def change
    create_table :order_status_changes do |t|
      t.bigint :order_id, null: false
      t.integer :order_status_id, null: false

      t.timestamps
    end
  end
end
