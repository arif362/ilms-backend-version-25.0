class AddIsAlbumRequestToAlbum < ActiveRecord::Migration[7.0]
  def change
    add_column :albums, :is_album_request, :boolean, default: false
  end
end
