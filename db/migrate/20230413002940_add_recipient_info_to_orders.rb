class AddRecipientInfoToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :recipient_name, :string
    add_column :orders, :recipient_phone, :string
    add_column :orders, :address_type, :integer, default: 0
  end
end
