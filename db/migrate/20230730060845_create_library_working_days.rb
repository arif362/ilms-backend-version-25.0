class CreateLibraryWorkingDays < ActiveRecord::Migration[7.0]
  def change
    create_table :library_working_days do |t|
      t.bigint :library_id
      t.integer :week_days
      t.boolean :is_default, default: false
      t.boolean :is_holiday, default: false
      t.string :start_time
      t.string :end_time
      t.bigint :created_by_id
      t.bigint :updated_by_id
      t.timestamps
    end
  end
end
