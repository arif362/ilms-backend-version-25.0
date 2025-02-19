class AddFieldsToLibrary < ActiveRecord::Migration[7.0]
  def change
    add_column :libraries, :bn_name, :string, null: false
    add_column :libraries, :library_type, :integer, null: false
    add_column :libraries, :lat, :string
    add_column :libraries, :long, :string
    add_column :libraries, :address, :string
    add_column :libraries, :bn_address, :string
    add_column :libraries, :ip_address, :string, null: false
    add_column :libraries, :code, :string, null: false
    add_column :libraries, :total_member_count, :integer, default: 0
    add_column :libraries, :total_user_count, :integer, default: 0
    add_column :libraries, :total_guest_count, :integer, default: 0
    add_column :libraries, :created_by, :bigint, null: false
    add_column :libraries, :updated_by, :bigint, null: false
    add_reference :libraries, :thana, index: true, foreign_key: true
  end
end
