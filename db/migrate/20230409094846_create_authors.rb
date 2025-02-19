class CreateAuthors < ActiveRecord::Migration[7.0]
  def change
    create_table :authors do |t|
      t.string :full_name, null: false
      t.string :title, null: false
      t.date :dob
      t.integer :created_by_id
      t.timestamps
    end
  end
end
