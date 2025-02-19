class AddPickUpLibraryIdToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :pick_up_library_id, :integer
  end
end
