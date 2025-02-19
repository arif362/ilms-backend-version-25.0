class ChangeTitleToAuthor < ActiveRecord::Migration[7.0]
  def change
    remove_column :authors, :title, :string, null: false
    add_column :authors, :title, :string
  end
end
