class CreateBiblioPublications < ActiveRecord::Migration[7.0]
  def change
    create_table :biblio_publications do |t|
      t.string :title
      t.datetime :deleted_at
      t.integer :created_by
      t.timestamps
    end
  end
end
