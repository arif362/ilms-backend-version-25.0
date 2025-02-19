class AddCreatedByIdAndUpdatedByIdToCollections < ActiveRecord::Migration[7.0]
  def change
    add_column :collections, :created_by_id, :bigint
    add_column :collections, :updated_by_id, :bigint
    add_column :collections, :is_deleted, :boolean, default: false
  end
end
