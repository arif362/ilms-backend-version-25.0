class CreateNotices < ActiveRecord::Migration[7.0]
  def change
    create_table :notices do |t|
      t.string :title
      t.text :description
      t.boolean :is_published, default: false
      t.datetime :published_date
      t.bigint :published_by_id
      t.bigint :created_by_id
      t.bigint :updated_by_id

      t.timestamps
    end
  end
end
