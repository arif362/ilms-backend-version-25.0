class AddColumnLibraryIdToReturnOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :return_orders, :library_id, :integer
  end
end
