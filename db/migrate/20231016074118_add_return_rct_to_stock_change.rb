class AddReturnRctToStockChange < ActiveRecord::Migration[7.0]
  def change
    add_column :stock_changes, :return_rct_3pl_quantity, :integer, default: 0
    add_column :stock_changes, :return_rct_3pl_quantity_change, :integer, default: 0
  end
end
