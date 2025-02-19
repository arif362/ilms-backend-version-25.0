class AddReturnAtToLibraryTransferOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :library_transfer_orders, :return_at, :datetime
  end
end
