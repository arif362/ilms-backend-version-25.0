class AddSmartCardNumberToLibraryCards < ActiveRecord::Migration[7.0]
  def change
    add_column :library_cards, :smart_card_number, :string
  end
end
