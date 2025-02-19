class AddColumnRecipientNameToSavedAddresses < ActiveRecord::Migration[7.0]
  def change
    add_column :saved_addresses, :recipient_name, :string
    add_column :saved_addresses, :recipient_phone, :string
  end
end
