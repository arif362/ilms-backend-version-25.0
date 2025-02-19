class AddDobToStaff < ActiveRecord::Migration[7.0]
  def change
    add_column :staffs, :dob, :datetime
    add_column :staffs, :joining_date, :datetime
    add_column :staffs, :staff_class, :string
    add_column :staffs, :staff_grade, :string
  end
end
