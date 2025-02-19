class AddGenderToMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :members, :gender, :integer
  end
end
