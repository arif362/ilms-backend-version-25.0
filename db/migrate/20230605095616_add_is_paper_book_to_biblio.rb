class AddIsPaperBookToBiblio < ActiveRecord::Migration[7.0]
  def change
    add_column :biblios, :is_paper_book, :boolean, default: false
    add_column :biblio_items, :is_ebook, :boolean, default: false
  end
end
