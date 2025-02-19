class AddVideoLinkToAlbumItem < ActiveRecord::Migration[7.0]
  def change
    add_column :album_items, :video_link, :string
  end
end
