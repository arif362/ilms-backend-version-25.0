class ChangeCaptionInAlbumItems < ActiveRecord::Migration[7.0]
  def change
    reversible do |rb|
      rb.up do
        change_column :album_items, :caption, :text
        change_column :album_items, :bn_caption, :text
      end
      rb.down do
        change_column :album_items, :caption, :string
        change_column :album_items, :bn_caption, :string
      end
    end
  end
end
