class ChangeColumnNullToPayments < ActiveRecord::Migration[7.0]
  def change
    change_column_null(:payments, :invoice_id, true)
  end
end
