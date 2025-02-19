class AddDeleteToKeyPeople < ActiveRecord::Migration[7.0]
  def change
    add_column :key_people, :is_deleted, :boolean, default: false
  end
end
