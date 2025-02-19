class AddAgeToMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :members, :age, :integer
  end
end
