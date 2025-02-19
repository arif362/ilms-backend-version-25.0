class RemoveLateDaysFromReturnOrders < ActiveRecord::Migration[7.0]
  def change
    remove_column :return_orders, :late_days, :integer
  end
end
