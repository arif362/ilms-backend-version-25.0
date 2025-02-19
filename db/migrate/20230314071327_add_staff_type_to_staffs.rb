class AddStaffTypeToStaffs < ActiveRecord::Migration[7.0]
  def change
    add_column :staffs, :staff_type, :integer
  end
end
