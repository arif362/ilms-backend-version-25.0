class AddDeliveryAreaAndIdToSavedAddresses < ActiveRecord::Migration[7.0]
  def change
    add_column :saved_addresses, :delivery_area, :string
    add_column :saved_addresses, :delivery_area_id, :integer
  end
end
