class AddColumnToBiblioItem < ActiveRecord::Migration[7.0]
  def change
    add_column :biblio_items, :central_accession_no, :string
  end
end
