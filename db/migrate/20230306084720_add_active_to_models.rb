class AddActiveToModels < ActiveRecord::Migration[7.0]
  def change
    # role status
    add_column :roles, :is_active, :boolean, default: true
    add_column :roles, :is_deleted, :boolean, default: false
    # staff status
    add_column :staffs, :is_deleted, :boolean, default: false
    # designation status
    add_column :designations, :is_active, :boolean, default: true
    add_column :designations, :is_deleted, :boolean, default: false
    # library status
    add_column :libraries, :is_active, :boolean, default: true
    add_column :libraries, :is_deleted, :boolean, default: false
    # location status
    add_column :divisions, :is_deleted, :boolean, default: false
    add_column :districts, :is_deleted, :boolean, default: false
    add_column :thanas, :is_deleted, :boolean, default: false
  end
end
