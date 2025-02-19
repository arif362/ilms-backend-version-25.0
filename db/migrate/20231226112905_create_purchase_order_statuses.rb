class CreatePurchaseOrderStatuses < ActiveRecord::Migration[7.0]
  def change
    create_table :purchase_order_statuses do |t|
      t.string :system_status
      t.string :admin_status
      t.string :publisher_status
      t.string :bn_publisher_status
      t.boolean :is_active, default: true
      t.boolean :is_deleted, default: false
      t.integer :status_key
      t.timestamps
    end
  end
end
