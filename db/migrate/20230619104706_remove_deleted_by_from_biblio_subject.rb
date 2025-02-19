class RemoveDeletedByFromBiblioSubject < ActiveRecord::Migration[7.0]
  def change
    remove_column :biblio_subjects, :deleted_by, :integer
    rename_column :biblio_subjects, :created_by, :created_by_id
    rename_column :biblio_subjects, :updated_by, :updated_by_id
  end
end
