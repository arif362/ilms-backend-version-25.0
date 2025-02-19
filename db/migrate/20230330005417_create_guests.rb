class CreateGuests < ActiveRecord::Migration[7.0]
  def change
    create_table :guests do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.integer :gender
      t.date :dob
      t.integer :library_id, null: false
      t.string :token, null: false, index: true
      t.bigint :created_by_id
      t.bigint :updated_by_id

      t.timestamps
    end
  end
end
