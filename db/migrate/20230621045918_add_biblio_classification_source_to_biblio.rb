class AddBiblioClassificationSourceToBiblio < ActiveRecord::Migration[7.0]
  def change
    add_column :biblios, :biblio_classification_source_id, :bigint
  end
end
