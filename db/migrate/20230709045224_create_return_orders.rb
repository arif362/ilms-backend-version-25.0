class CreateReturnOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :return_orders do |t|
      t.bigint :user_id
      t.integer :delivery_type
      t.integer :address_type
      t.text :address
      t.integer :division_id
      t.integer :district_id
      t.integer :thana_id
      t.text :note
      t.integer :return_status_id
      t.integer :late_days, default: 0

      t.timestamps
    end
  end
end
