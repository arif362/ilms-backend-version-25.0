class AddReturnOrderIdToCirculations < ActiveRecord::Migration[7.0]
  def change
    add_column :circulations, :return_order_id, :integer
  end
end
