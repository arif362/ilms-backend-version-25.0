class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.references :user
      t.references :library
      t.references :division
      t.references :district
      t.references :thana
      t.text :address
      t.decimal :total, precision: 10, scale: 4, default: 0
      t.integer :status, default: 0
      t.integer :delivery_type, default: 0
      t.text :note

      t.timestamps
    end
  end
end
