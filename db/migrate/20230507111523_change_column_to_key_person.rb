class ChangeColumnToKeyPerson < ActiveRecord::Migration[7.0]
  def change
    remove_column :key_people, :description, :string
    remove_column :key_people, :bn_description, :string
    add_column :key_people, :description, :json
    add_column :key_people, :bn_description, :json
  end
end
