class CreateAlbums < ActiveRecord::Migration[7.0]
  def change
    create_table :albums do |t|
      t.string :title, null: false
      t.string :bn_title, null: false
      t.string :description, null: false
      t.string :bn_description, null: false
      t.boolean :is_visible, default: true
      t.boolean :is_deleted, default: false
      t.timestamps
    end
  end
end
