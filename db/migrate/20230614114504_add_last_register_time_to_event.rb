class AddLastRegisterTimeToEvent < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :registration_last_date, :datetime
  end
end
