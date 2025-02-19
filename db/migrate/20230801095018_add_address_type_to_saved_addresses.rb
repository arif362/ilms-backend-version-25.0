class AddAddressTypeToSavedAddresses < ActiveRecord::Migration[7.0]
  def change
    add_column :saved_addresses, :address_type, :integer, default: 0
  end
end
