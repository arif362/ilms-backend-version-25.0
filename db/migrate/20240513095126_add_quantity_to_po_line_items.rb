class AddQuantityToPoLineItems < ActiveRecord::Migration[7.0]
  def change
    add_column :po_line_items, :received_quantity, :integer, default: 0
  end
end
