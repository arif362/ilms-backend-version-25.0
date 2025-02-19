class AddSlugToKeyPeople < ActiveRecord::Migration[7.0]
  def change
    add_column :key_people, :slug, :string, null: false
  end
end
