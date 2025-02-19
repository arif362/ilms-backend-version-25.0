class CreateCardStatuses < ActiveRecord::Migration[7.0]
  def change
    create_table :card_statuses do |t|
      t.string :admin_status
      t.string :patron_status
      t.string :bn_patron_status
      t.string :lms_status
      t.integer :status_key
      t.boolean :is_active
      t.boolean :is_deleted

      t.timestamps
    end
  end
end
