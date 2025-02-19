class AddColumnsToAlbum < ActiveRecord::Migration[7.0]
  def change
    add_column :albums, :created_by_id, :bigint, null: false
    add_column :albums, :updated_by_id, :bigint
    add_column :albums, :library_id, :bigint
    add_column :albums, :event_id, :bigint
    add_column :albums, :status, :integer, default: 0
    add_column :albums, :album_type, :integer, default: 0
    add_column :albums, :is_event_album, :boolean, default: false
    add_column :albums, :published_at, :datetime
    add_column :albums, :total_items, :integer, default: 0
    remove_column :albums, :description, :string, null: false
    remove_column :albums, :bn_description, :string, null: false
    remove_column :albums, :is_deleted, :boolean, default: false
  end
end
