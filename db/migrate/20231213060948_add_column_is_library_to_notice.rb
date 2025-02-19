class AddColumnIsLibraryToNotice < ActiveRecord::Migration[7.0]
  def change
    add_column :notices, :notice_type, :integer, default: 0
  end
end
