class CreateCartItems < ActiveRecord::Migration[7.0]
  def change
    create_table :cart_items do |t|
      t.references :cart
      t.references :biblio
      t.references :biblio_item
      t.decimal :price, precision: 10, scale: 4, default: 0

      t.timestamps
    end
  end
end
