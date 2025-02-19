class AddTrxIdToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :trx_id, :string
  end
end
