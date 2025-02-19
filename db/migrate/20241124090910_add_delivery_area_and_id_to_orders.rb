class AddDeliveryAreaAndIdToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :delivery_area, :string
    add_column :orders, :delivery_area_id, :integer
  end
end
