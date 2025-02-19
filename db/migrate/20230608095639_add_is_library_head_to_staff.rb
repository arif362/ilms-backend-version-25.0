class AddIsLibraryHeadToStaff < ActiveRecord::Migration[7.0]
  def change
    add_column :staffs, :is_library_head, :boolean, default: false
    add_column :libraries, :email, :string
  end
end
