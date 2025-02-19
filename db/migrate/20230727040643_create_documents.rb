class CreateDocuments < ActiveRecord::Migration[7.0]
  def change
    create_table :documents do |t|
      t.string :name
      t.string :bn_name
      t.string :description
      t.string :bn_description
      t.integer :document_category_id
      t.integer :created_by
      t.timestamps
    end
  end
end
