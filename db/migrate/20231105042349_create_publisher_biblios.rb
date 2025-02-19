class CreatePublisherBiblios < ActiveRecord::Migration[7.0]
  def change
    create_table :publisher_biblios do |t|
      t.bigint :memorandum_publisher_id
      t.string :author_name
      t.string :title
      t.string :publisher_name
      t.string :publisher_phone
      t.string :publisher_address
      t.date :publication_date
      t.string :publisher_website
      t.string :edition
      t.string :print
      t.integer :total_page, default: 0
      t.string :subject
      t.float :price, default: 0.0
      t.string :isbn
      t.integer :paper_type, default: 0
      t.integer :binding_type, default: 0
      t.string :comment
      t.boolean :is_foreign, default: false
      t.boolean :is_shortlisted, default: false
      t.timestamps
    end
  end
end
