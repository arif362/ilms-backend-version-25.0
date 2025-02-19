class AddColumnAddressDivisionDisThanaToRequestDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :request_details, :present_division_id, :integer
    add_column :request_details, :present_district_id, :integer
    add_column :request_details, :present_thana_id, :integer

    add_column :request_details, :permanent_division_id, :integer
    add_column :request_details, :permanent_district_id, :integer
    add_column :request_details, :permanent_thana_id, :integer

    add_column :members, :present_division_id, :integer
    add_column :members, :present_district_id, :integer
    add_column :members, :present_thana_id, :integer

    add_column :members, :permanent_division_id, :integer
    add_column :members, :permanent_district_id, :integer
    add_column :members, :permanent_thana_id, :integer
  end
end
