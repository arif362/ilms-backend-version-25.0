class CreateComplains < ActiveRecord::Migration[7.0]
  def change
    create_table :complains do |t|
      t.integer :complain_type, default: 0
      t.integer :action_type, default: 0
      t.references :library
      t.references :user
      t.boolean :is_deleted, default: false
      t.boolean :is_anonymous, default: false
      t.json :description
      t.json :reply
      t.boolean :send_notification, default: false
      t.boolean :sent_email, default: false
      t.timestamps
    end
  end
end
