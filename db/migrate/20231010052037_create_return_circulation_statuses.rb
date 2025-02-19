class CreateReturnCirculationStatuses < ActiveRecord::Migration[7.0]
  def change
    create_table :return_circulation_statuses do |t|
      t.string :system_status, null: false
      t.string :admin_status, null: false
      t.string :lms_status, null: false
      t.boolean :is_active, default: true
      t.boolean :is_deleted, default: false
      t.integer :status_key, default: 0
      t.timestamps
    end
  end
end
