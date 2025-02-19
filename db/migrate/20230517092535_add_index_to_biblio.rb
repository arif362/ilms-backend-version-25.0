class AddIndexToBiblio < ActiveRecord::Migration[7.0]
  def change
    add_index :biblios, :title
    add_column :biblios, :unique_biblio, :string, default: ''
    change_column :biblios, :general_note, :string
    change_column :biblios, :bibliography_note, :string
    change_column :biblios, :contents_note, :string
    change_column :biblios, :topical_term, :string
    change_column :biblios, :series_statement_title, :string
    change_column :biblios, :series_statement_volume, :string
    change_column :biblios, :isbn, :string
  end
end
