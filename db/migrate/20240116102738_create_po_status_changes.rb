class CreatePoStatusChanges < ActiveRecord::Migration[7.0]
  def change
    create_table :po_status_changes do |t|
      t.references :purchase_order
      t.references :purchase_order_status
      t.integer "changed_by_id"
      t.string "changed_by_type"
      t.timestamps
    end
  end
end
