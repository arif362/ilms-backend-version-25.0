class AddUpdatedByIdToBiblioClassificationSource < ActiveRecord::Migration[7.0]
  def change
    rename_column :biblio_classification_sources, :created_by, :created_by_id
    add_column :biblio_classification_sources, :updated_by_id, :integer
    add_column :biblio_classification_sources, :is_deleted, :boolean, default: false
  end
end
