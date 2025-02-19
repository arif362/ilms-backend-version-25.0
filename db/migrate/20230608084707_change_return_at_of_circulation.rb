class ChangeReturnAtOfCirculation < ActiveRecord::Migration[7.0]

  def up
    change_column :circulations, :return_at, :datetime, precision: 6
    change_column :circulations, :returned_at, :datetime, precision: 6
  end

  def down
    change_column :circulations, :return_at, :date
    change_column :circulations, :returned_at, :date
  end
end
