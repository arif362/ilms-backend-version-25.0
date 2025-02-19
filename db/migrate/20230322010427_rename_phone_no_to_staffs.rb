class RenamePhoneNoToStaffs < ActiveRecord::Migration[7.0]
  def change
    rename_column :staffs, :phone_number, :phone
  end
end
