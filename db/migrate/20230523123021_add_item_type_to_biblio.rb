class AddItemTypeToBiblio < ActiveRecord::Migration[7.0]
  def change
    add_reference :biblios, :item_type
  end
end
