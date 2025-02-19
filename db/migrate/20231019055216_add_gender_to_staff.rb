class AddGenderToStaff < ActiveRecord::Migration[7.0]
  def change
    add_column :staffs, :gender, :integer, default: 0
  end
end
