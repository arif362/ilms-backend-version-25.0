class CreateAnnouncements < ActiveRecord::Migration[7.0]
  def change
    create_table :announcements do |t|
      t.string :title, null: false
      t.string :bn_title, null: false
      t.integer :notification_type, null: false
      t.string :description, null: false
      t.string :bn_description, null: false
      t.integer :announcement_for, null: false

      t.timestamps
    end
  end
end
