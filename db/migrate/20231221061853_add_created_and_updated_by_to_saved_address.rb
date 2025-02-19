class AddCreatedAndUpdatedByToSavedAddress < ActiveRecord::Migration[7.0]
  def change
    add_column :saved_addresses, :created_by_id, :bigint
    add_column :saved_addresses, :updated_by_id, :bigint
    add_column :saved_addresses, :created_by_type, :string
    add_column :saved_addresses, :updated_by_type, :string
  end
end
