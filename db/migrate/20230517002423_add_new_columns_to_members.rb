class AddNewColumnsToMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :members, :institute_address, :string
    add_column :members, :student_class, :string
    add_column :members, :student_section, :string
    add_column :members, :student_id, :string
  end
end
