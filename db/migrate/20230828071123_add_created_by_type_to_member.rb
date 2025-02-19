class AddCreatedByTypeToMember < ActiveRecord::Migration[7.0]
  def change
    add_column :members, :created_by_type, :string
    add_column :members, :updated_by_type, :string
  end
end
