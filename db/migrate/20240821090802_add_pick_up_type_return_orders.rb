class AddPickUpTypeReturnOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :return_orders, :return_type, :integer
  end
end
