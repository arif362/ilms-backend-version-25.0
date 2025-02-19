class AddCreatedByAndUpdatedByToRequestedBiblios < ActiveRecord::Migration[7.0]
  def change
    add_column :requested_biblios, :updated_by_id, :integer
    add_column :requested_biblios, :updated_by_type, :string
    add_column :requested_biblios, :created_by_id, :integer
    add_column :requested_biblios, :created_by_type, :string
    add_column :requested_biblios, :library_id, :integer
  end
end
