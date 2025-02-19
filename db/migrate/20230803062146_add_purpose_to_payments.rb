class AddPurposeToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :purpose, :integer, default: 0
  end
end
