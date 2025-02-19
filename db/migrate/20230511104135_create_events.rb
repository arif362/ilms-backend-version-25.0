class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.string :title
      t.string :bn_title
      t.json :details
      t.json :bn_details
      t.boolean :is_published, default: true
      t.boolean :is_deleted, default: false
      t.boolean :is_all_library, default: false
      t.boolean :is_registerable, default: false
      t.boolean :is_all_user, default: false
      t.date :start_date
      t.date :end_date
      t.time :start_time
      t.time :end_time
      t.string :membership_category, default: [].to_yaml
      t.integer :total_registered, default: 0
      t.timestamps
    end
  end
end
