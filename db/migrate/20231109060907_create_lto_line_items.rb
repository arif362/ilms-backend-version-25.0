class CreateLtoLineItems < ActiveRecord::Migration[7.0]
  def change
    create_table :lto_line_items do |t|
      t.integer :library_transfer_order_id
      t.integer :biblio_id
      t.integer :biblio_item_id
      t.integer :price, default: 0
      t.integer :quantity, default: 0

      t.timestamps
    end
  end
end
