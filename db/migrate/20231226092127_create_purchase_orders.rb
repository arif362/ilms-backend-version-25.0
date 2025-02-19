class CreatePurchaseOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :purchase_orders do |t|
      t.references :memorandum
      t.references :publisher
      t.references :memorandum_publisher
      t.references :purchase_order_status, default: 1
      t.datetime :last_submission_date
      t.integer :created_by_id
      t.integer :created_by_type
      t.integer :updated_by_id
      t.string :updated_by_type
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
