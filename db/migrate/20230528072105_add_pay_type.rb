class AddPayType < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :pay_type, :integer, default: 0
    add_column :library_cards, :pay_type, :integer, default: 0
  end
end
