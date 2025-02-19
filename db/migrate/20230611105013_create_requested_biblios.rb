class CreateRequestedBiblios < ActiveRecord::Migration[7.0]
  def change
    create_table :requested_biblios do |t|
      t.string :biblio_title
      t.string :author_name
      t.string :biblio_subject
      t.string :isbn
      t.string :other_authors
      t.string :publication
      t.string :edition
      t.integer :number_of_pages
      t.bigint :user_id
      t.timestamps
    end
  end
end
