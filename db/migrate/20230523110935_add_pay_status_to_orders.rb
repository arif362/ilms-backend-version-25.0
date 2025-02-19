class AddPayStatusToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :pay_status, :integer, default: 0
  end
end
