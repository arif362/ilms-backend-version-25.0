class AddColumnRefCardIdToLibraryCards < ActiveRecord::Migration[7.0]
  def change
    add_column :library_cards, :reference_card_id, :integer
  end
end
