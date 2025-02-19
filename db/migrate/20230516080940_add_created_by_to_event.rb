class AddCreatedByToEvent < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :created_by, :integer
    add_column :events, :updated_by, :integer
  end
end
