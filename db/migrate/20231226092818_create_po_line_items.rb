class CreatePoLineItems < ActiveRecord::Migration[7.0]
  def change
    create_table :po_line_items do |t|
      t.references :purchase_order
      t.references :publisher_biblio
      t.integer :quantity, default: 0
      t.float :price, default: 0.0
      t.datetime :received_at
      t.integer :sub_total, default: 0.0
      t.string :bar_code
      t.string :purchase_code
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
