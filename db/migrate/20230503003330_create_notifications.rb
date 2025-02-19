class CreateNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :notifications do |t|
      t.references :notificationable, polymorphic: true
      t.references :notifiable, polymorphic: true
      t.text :message
      t.text :message_bn
      t.boolean :is_read, default: false

      t.timestamps
    end
  end
end
