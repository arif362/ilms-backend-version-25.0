class AddCreatedByIdAndUpdatedByIdToMemorandum < ActiveRecord::Migration[7.0]
  def change
    add_column :memorandums, :created_by_id, :bigint, null: false
    add_column :memorandums, :updated_by_id, :bigint
    add_column :memorandums, :is_deleted, :boolean, default: false
  end
end
