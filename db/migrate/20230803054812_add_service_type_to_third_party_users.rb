class AddServiceTypeToThirdPartyUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :third_party_users, :service_type, :integer, default: 0
    add_column :third_party_users, :name, :string
  end
end
