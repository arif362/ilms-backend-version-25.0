class CreateEBooks < ActiveRecord::Migration[7.0]
  def change
    create_table :e_books do |t|
      t.integer :book_type, default: 0
      t.string :title
      t.string :author
      t.string :author_url
      t.string :book_url
      t.integer :year
      t.integer :created_by_id
      t.integer :updated_by_id
      t.string :publisher
      t.boolean :is_published, default: true

      t.timestamps
    end
  end
end
