class AddTotalFineToReturnOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :return_orders, :total_fine, :integer, default: 0
  end
end
