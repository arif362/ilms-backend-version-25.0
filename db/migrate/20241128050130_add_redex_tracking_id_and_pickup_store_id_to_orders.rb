class AddRedexTrackingIdAndPickupStoreIdToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :tracking_id, :string
    add_column :orders, :pickup_store_id, :integer
  end
end
