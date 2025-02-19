class AddColumnPermissionCodesToRoles < ActiveRecord::Migration[7.0]
  def change
    add_column :roles, :permission_codes, :text, array: true
  end
end
