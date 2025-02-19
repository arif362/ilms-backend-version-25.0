class CreateGoodsReceipts < ActiveRecord::Migration[7.0]
  def change
    create_table :goods_receipts do |t|
      t.references :purchase_order
      t.references :publisher
      t.references :memorandum_publisher
      t.references :publisher_biblio
      t.references :po_line_item
      t.integer :quantity, default: 0
      t.float :price, default: 0.0
      t.integer :sub_total, default: 0.0
      t.string :bar_code
      t.string :purchase_code
      t.integer :created_by_id
      t.integer :created_by_type
      t.integer :updated_by_id
      t.string :updated_by_type
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
