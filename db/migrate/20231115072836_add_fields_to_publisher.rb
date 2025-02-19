class AddFieldsToPublisher < ActiveRecord::Migration[7.0]
  def change
    add_column :publishers, :organization_phone, :string
    add_column :publishers, :organization_email, :string
  end
end
