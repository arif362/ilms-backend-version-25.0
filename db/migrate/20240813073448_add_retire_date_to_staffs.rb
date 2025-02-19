class AddRetireDateToStaffs < ActiveRecord::Migration[7.0]
  def change
    add_column :staffs, :retired_date, :datetime
  end
end
