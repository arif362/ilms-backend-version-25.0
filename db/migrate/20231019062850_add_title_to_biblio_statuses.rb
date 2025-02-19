class AddTitleToBiblioStatuses < ActiveRecord::Migration[7.0]
  def change
    add_column :biblio_statuses, :title, :string
    add_column :biblio_statuses, :created_by_id, :integer
    add_column :biblio_statuses, :updated_by_id, :integer
  end
end
