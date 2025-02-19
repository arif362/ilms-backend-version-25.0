class AddSanctionedPostAndJoinedLibraryId < ActiveRecord::Migration[7.0]
  def change
    add_column :staffs, :sanctioned_post, :string
    add_column :staffs, :joining_library_id, :integer
  end
end
