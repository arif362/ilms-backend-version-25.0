class AddNewColumnsToRequestDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :request_details, :institute_address, :string
    add_column :request_details, :student_class, :string
    add_column :request_details, :student_section, :string
    add_column :request_details, :student_id, :string
    add_column :request_details, :card_delivery_type, :integer, default: 0
    add_column :request_details, :delivery_address_type, :integer, default: 0
    add_column :request_details, :recipient_name, :string
    add_column :request_details, :recipient_phone, :string
    add_column :request_details, :delivery_division_id, :integer
    add_column :request_details, :delivery_district_id, :integer
    add_column :request_details, :delivery_thana_id, :integer
    add_column :request_details, :delivery_address, :string
    add_column :request_details, :note, :text
  end
end
