class AddColumnsToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :created_by_type, :string
    add_column :payments, :updated_by_type, :string
  end
end
