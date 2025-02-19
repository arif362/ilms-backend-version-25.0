class AddColumnUpdatedByIdToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :updated_by_id, :integer
    add_column :orders, :updated_by_type, :string
  end
end
