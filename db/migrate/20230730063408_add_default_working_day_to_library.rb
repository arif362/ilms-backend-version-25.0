class AddDefaultWorkingDayToLibrary < ActiveRecord::Migration[7.0]
  def change
    add_column :libraries, :is_default_working_days, :boolean, default: true
  end
end
