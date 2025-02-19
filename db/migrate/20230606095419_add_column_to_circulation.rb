class AddColumnToCirculation < ActiveRecord::Migration[7.0]
  def change
    add_column :circulations, :updated_by_id, :integer
    add_column :circulations, :updated_by_type, :string

    add_column :circulation_statuses, :status_key, :integer, default: 0
    add_column :circulation_statuses, :lms_status, :string, null: false

    add_column :circulation_status_changes, :changed_by_type, :string
    rename_column :circulation_status_changes, :created_by_id, :changed_by_id
  end
end
