class AddColumnDiliveryAddressToLibraryCrads < ActiveRecord::Migration[7.0]
  def change
    add_column :library_cards, :delivery_address, :string
  end
end
