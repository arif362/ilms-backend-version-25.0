class AddDatesToLibraryTransferOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :library_transfer_orders, :start_date, :datetime, null: true
    add_column :library_transfer_orders, :end_date, :datetime, null: true
  end
end
