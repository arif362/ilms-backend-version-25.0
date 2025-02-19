class AddOptionValueToItemType < ActiveRecord::Migration[7.0]
  def change
    add_column :item_types, :option_value, :string
  end
end
