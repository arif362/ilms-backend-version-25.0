class AddUpdatedByToBiblioPublication < ActiveRecord::Migration[7.0]
  def change
    add_column :biblio_publications,  :updated_by_id, :bigint
    add_column :biblio_publications,  :is_deleted, :boolean, default: false
  end
end
