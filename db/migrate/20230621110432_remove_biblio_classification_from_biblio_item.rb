class RemoveBiblioClassificationFromBiblioItem < ActiveRecord::Migration[7.0]
  def change
    remove_column :biblio_items, :biblio_classification_id, :integer
    remove_column :biblio_items, :biblio_status_id, :integer
    add_column :biblio_items, :created_by_id, :integer
    add_column :biblio_items, :updated_by_id, :integer
  end
end
