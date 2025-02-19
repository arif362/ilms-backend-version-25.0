class AddBiblioItemTypeToBiblioItem < ActiveRecord::Migration[7.0]
  def change
    add_column :biblio_items, :biblio_item_type, :integer, default: 0
    remove_column :biblio_items, :is_ebook, :boolean, default: false
    rename_column :biblios, :is_ebook, :is_e_biblio
    rename_column :biblios, :is_paper_book, :is_paper_biblio
  end
end
