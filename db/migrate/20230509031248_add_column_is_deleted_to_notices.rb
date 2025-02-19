class AddColumnIsDeletedToNotices < ActiveRecord::Migration[7.0]
  def change
    add_column :notices, :is_deleted, :boolean, default: false
  end
end
