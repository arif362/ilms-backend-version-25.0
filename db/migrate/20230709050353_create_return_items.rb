class CreateReturnItems < ActiveRecord::Migration[7.0]
  def change
    create_table :return_items do |t|
      t.bigint :biblio_id
      t.bigint :biblio_item_id
      t.bigint :line_item_id
      t.bigint :return_order_id

      t.timestamps
    end
  end
end
