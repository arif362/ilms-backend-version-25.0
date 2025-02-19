class CreateInvoicesPayments < ActiveRecord::Migration[7.0]
  def change
    create_table :invoices_payments do |t|
      t.integer :payment_id
      t.integer :invoice_id

      t.timestamps
    end
  end
end
