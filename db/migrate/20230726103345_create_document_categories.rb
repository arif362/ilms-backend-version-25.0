class CreateDocumentCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :document_categories do |t|
      t.string :name
      t.integer :created_by
      t.timestamps
    end
  end
end
