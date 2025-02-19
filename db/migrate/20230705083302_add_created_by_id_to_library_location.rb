class AddCreatedByIdToLibraryLocation < ActiveRecord::Migration[7.0]
  def change
    add_column :library_locations, :created_by_id, :bigint
    add_column :library_locations, :updated_by_id, :bigint
    add_column :library_locations, :is_deleted, :boolean, default: false
    add_column :library_locations, :deleted_at, :datetime
  end
end
