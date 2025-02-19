class AddColumnsToLibraryTransferOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :library_transfer_orders, :transferable_type, :string
    add_column :library_transfer_orders, :transferable_id, :integer
    add_column :library_transfer_orders, :order_type, :integer, default: 0
  end
end
