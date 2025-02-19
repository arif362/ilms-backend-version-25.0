class AddPickupStoreIdToLibraries < ActiveRecord::Migration[7.0]
  def change
    add_column :libraries, :redx_pickup_store_id, :integer
  end
end
