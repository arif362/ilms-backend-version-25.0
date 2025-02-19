class CreateBiblioEditions < ActiveRecord::Migration[7.0]
  def change
    create_table :biblio_editions do |t|
      t.string :title
      t.text :description
      t.datetime :deleted_at
      t.integer :created_by
      t.timestamps
    end
  end
end
