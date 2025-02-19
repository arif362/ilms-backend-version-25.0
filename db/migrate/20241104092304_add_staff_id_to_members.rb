class AddStaffIdToMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :members, :staff_id, :integer
  end
end
