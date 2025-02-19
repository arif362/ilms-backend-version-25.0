class CreateBiblioClassificationSources < ActiveRecord::Migration[7.0]
  def change
    create_table :biblio_classification_sources do |t|
      t.string :title
      t.datetime :deleted_at
      t.integer :created_by
      t.timestamps
    end
  end
end
