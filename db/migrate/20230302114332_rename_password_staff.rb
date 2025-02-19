class RenamePasswordStaff < ActiveRecord::Migration[7.0]
  def change
    rename_column :staffs, :password, :password_hash
  end
end
