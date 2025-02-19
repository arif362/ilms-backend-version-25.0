class AddUpdatedByIdAndTypeToBookTransferOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :book_transfer_orders, :updated_by_id, :integer
    add_column :book_transfer_orders, :updated_by_type, :string
  end
end
