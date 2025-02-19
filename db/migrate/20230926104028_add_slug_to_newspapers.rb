class AddSlugToNewspapers < ActiveRecord::Migration[7.0]
  def change
    add_column :newspapers, :slug, :string
    add_index :newspapers, :slug, unique: true
  end
end
