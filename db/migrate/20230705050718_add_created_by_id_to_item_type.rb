class AddCreatedByIdToItemType < ActiveRecord::Migration[7.0]
  def change
    add_column :item_types, :created_by_id, :bigint
    add_column :item_types, :updated_by_id, :bigint
    add_column :item_types, :is_deleted, :boolean, default: false
    add_column :item_types, :deleted_at, :datetime
  end
end
