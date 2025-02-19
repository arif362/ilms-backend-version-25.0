class AddShippingChargeAndVatToInvoices < ActiveRecord::Migration[7.0]
  def change
    add_column :invoices, :shipping_charge, :integer, default: 0, null: false
    add_column :invoices, :shipping_charge_vat, :decimal, precision: 6, scale: 2, default: 0.0
  end
end
