class AddIsIlsAdminAndIsLmsAdminToStaffs < ActiveRecord::Migration[7.0]
  def change
    add_column :staffs, :is_ils_system_admin, :boolean, default: false
    add_column :staffs, :is_lms_system_admin, :boolean, default: false
  end
end
