class AddCreatedByIdToBiblio < ActiveRecord::Migration[7.0]
  def change
    add_column :biblios, :created_by_id, :bigint
    add_column :biblios, :updated_by_id, :bigint
  end
end
