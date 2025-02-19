class CreateReturnStatuses < ActiveRecord::Migration[7.0]
  def change
    create_table :return_statuses do |t|
      t.integer :status_key
      t.string :admin_status
      t.string :lms_status
      t.string :patron_status
      t.string :bn_patron_status
      t.boolean :is_active
      t.boolean :is_deleted

      t.timestamps
    end
  end
end
