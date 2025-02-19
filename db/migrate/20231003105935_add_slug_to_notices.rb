class AddSlugToNotices < ActiveRecord::Migration[7.0]
  def change
    add_column :notices, :slug, :string
    add_index :notices, :slug, unique: true
  end
end
