class AddLastNameToAuthor < ActiveRecord::Migration[7.0]
  def change
    rename_column :authors, :full_name, :first_name
    rename_column :authors, :bn_full_name, :bn_first_name
    add_column :authors, :middle_name, :string
    add_column :authors, :bn_middle_name, :string
    add_column :authors, :last_name, :string
    add_column :authors, :bn_last_name, :string
    add_column :authors, :title, :string
    add_column :authors, :bn_title, :string
    add_column :authors, :updated_by_id, :integer
    add_column :authors, :is_deleted, :boolean, default: false
    add_column :authors, :deleted_at, :datetime
  end
end
