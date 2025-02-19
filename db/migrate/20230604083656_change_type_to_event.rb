class ChangeTypeToEvent < ActiveRecord::Migration[7.0]
  def change
    remove_column :events, :start_time, :time
    remove_column :events, :start_date, :date
    remove_column :events, :end_date, :date
    remove_column :events, :end_time, :time
    add_column :events, :start_date, :datetime
    add_column :events, :end_date, :datetime
  end
end
