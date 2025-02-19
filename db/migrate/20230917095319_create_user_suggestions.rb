class CreateUserSuggestions < ActiveRecord::Migration[7.0]
  def change
    create_table :user_suggestions do |t|
      t.integer :user_id
      t.integer :biblio_id
      t.string :biblio_title
      t.integer :biblio_subject_id
      t.integer :author_id
      t.integer :read_count, default: 0
      t.integer :search_count, default: 0
      t.integer :borrow_count, default: 0
      t.timestamps
    end
  end
end
