class CreateBookTransferOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :book_transfer_orders do |t|
      t.integer :user_id
      t.integer :biblio_id
      t.integer :library_id
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
