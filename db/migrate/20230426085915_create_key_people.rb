class CreateKeyPeople < ActiveRecord::Migration[7.0]
  def change
    create_table :key_people do |t|
      t.string :name
      t.string :bn_name
      t.string :designation
      t.string :bn_designation
      t.text :description
      t.text :bn_description
      t.integer :position
      t.boolean :is_active
      t.timestamps
    end
  end
end
