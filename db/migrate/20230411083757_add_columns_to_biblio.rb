class AddColumnsToBiblio < ActiveRecord::Migration[7.0]
  def change
    add_column :biblios, :slug, :string, null: false
    add_column :biblios, :is_ebook, :boolean, null: false, default: false
  end
end
