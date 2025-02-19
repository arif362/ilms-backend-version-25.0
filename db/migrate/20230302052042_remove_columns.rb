class RemoveColumns < ActiveRecord::Migration[7.0]
  def change
    remove_column :roles, :bn_title
    remove_column :designations, :bn_title
    remove_column :staffs, :admin_type
  end
end
