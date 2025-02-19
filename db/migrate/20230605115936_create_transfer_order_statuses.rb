class CreateTransferOrderStatuses < ActiveRecord::Migration[7.0]
  def change
    create_table :transfer_order_statuses do |t|
      t.string :system_status, null: false
      t.string :admin_status, null: false
      t.string :patron_status, null: false
      t.string :bn_patron_status, null: false
      t.boolean :is_active, default: true
      t.boolean :is_deleted, default: false
      t.integer :status_key, default: 0
      t.string :lms_status, null: false
      t.timestamps
    end
  end
end
