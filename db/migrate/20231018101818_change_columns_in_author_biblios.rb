class ChangeColumnsInAuthorBiblios < ActiveRecord::Migration[7.0]
  def change
    remove_column :author_biblios, :is_primary
    add_column :author_biblios, :responsibility, :string
  end
end
