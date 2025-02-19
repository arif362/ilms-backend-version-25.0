class RenameNameToAuthor < ActiveRecord::Migration[7.0]
  def change
    remove_column :authors, :title, :string
    add_column :authors, :bn_full_name, :string, null: false
    add_column :biblio_publications, :bn_title, :string, null: false
  end
end
