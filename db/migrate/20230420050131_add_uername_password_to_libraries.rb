class AddUernamePasswordToLibraries < ActiveRecord::Migration[7.0]
  def change
    add_column :libraries, :username, :string, index: true, null: true
    add_column :libraries, :password_hash, :string
  end
end
