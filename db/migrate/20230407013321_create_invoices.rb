class CreateInvoices < ActiveRecord::Migration[7.0]
  def change
    create_table :invoices do |t|
      t.bigint :invoiceable_id, null: false
      t.string :invoiceable_type, null: false
      t.integer :invoice_type, null: false
      t.integer :invoice_status, default: 0, null: false
      t.integer :invoice_amount, default: 0, null: false
      t.bigint :user_id, null: false
      t.bigint :created_by_id
      t.bigint :updated_by_id

      t.timestamps
    end
  end
end
