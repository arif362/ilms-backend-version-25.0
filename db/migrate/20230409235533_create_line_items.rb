class CreateLineItems < ActiveRecord::Migration[7.0]
  def change
    create_table :line_items do |t|
      t.references :order
      t.references :biblio
      t.references :biblio_item
      t.decimal :price, precision: 10, scale: 4, default: 0

      t.timestamps
    end
  end
end
