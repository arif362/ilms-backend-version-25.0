class CreateAlbumItems < ActiveRecord::Migration[7.0]
  def change
    create_table :album_items do |t|
      t.references :album, foreign_keys: true
      t.string :caption
      t.string :bn_caption
      t.timestamps
    end
  end
end
