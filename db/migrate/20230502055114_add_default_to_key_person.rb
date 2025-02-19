class AddDefaultToKeyPerson < ActiveRecord::Migration[7.0]
  def change
    change_column_default :key_people, :is_active, default: true
  end
end
