class AddNoteToBookTransferOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :book_transfer_orders, :note, :text
  end
end
