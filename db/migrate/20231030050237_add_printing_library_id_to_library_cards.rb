class AddPrintingLibraryIdToLibraryCards < ActiveRecord::Migration[7.0]
  def change
    add_column :library_cards, :printing_library_id, :integer
  end
end
