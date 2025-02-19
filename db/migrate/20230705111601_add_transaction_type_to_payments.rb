class AddTransactionTypeToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :transaction_type, :integer, default: 0
  end
end
