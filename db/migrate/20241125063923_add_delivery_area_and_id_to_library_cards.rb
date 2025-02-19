class AddDeliveryAreaAndIdToLibraryCards < ActiveRecord::Migration[7.0]
  def change
    add_column :library_cards, :delivery_area, :string
    add_column :library_cards, :delivery_area_id, :integer
  end
end
