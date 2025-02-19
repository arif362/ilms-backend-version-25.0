class AddOrderIdToCirculations < ActiveRecord::Migration[7.0]
  def change
    add_column :circulations, :order_id, :integer
  end
end
