class AddFieldsToBiblios < ActiveRecord::Migration[7.0]
  def change
    add_column :biblios, :preview_ebook_file_url, :string
    add_column :biblios, :full_ebook_file_url, :string
  end
end
