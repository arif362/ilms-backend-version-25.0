class CreatePoPayments < ActiveRecord::Migration[7.0]
  def change
    create_table :po_payments do |t|
      t.integer :payment_type, default: 0, null: false
      t.integer :status, default: 0, null: false
      t.string :form_of_payment
      t.bigint :invoice_id, null: false
      t.integer :amount, null: false, default: 0
      t.bigint :created_by_id
      t.bigint :updated_by_id
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
