class CreateLibraryTransferOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :library_transfer_orders do |t|
      t.references :biblio
      t.references :user
      t.integer :sender_library_id
      t.integer :receiver_library_id
      t.references :transfer_order_status
      t.integer :updated_by_id
      t.string :updated_by_type
      t.timestamps
    end
  end
end
