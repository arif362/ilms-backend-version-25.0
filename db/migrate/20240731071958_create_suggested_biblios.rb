class CreateSuggestedBiblios < ActiveRecord::Migration[7.0]
  def change
    create_table :suggested_biblios do |t|
      t.integer :user_id
      t.integer :biblio_id
      t.integer :read_count, default: 0
      t.integer :borrow_count, default: 0
      t.integer :points, default: 0

      t.timestamps
    end
  end
end
