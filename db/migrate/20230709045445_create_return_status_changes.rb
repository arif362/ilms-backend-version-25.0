class CreateReturnStatusChanges < ActiveRecord::Migration[7.0]
  def change
    create_table :return_status_changes do |t|
      t.bigint :return_order_id
      t.integer :return_status_id
      t.bigint :changed_by_id
      t.string :changed_by_type

      t.timestamps
    end
  end
end
