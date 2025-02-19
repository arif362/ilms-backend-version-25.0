class AddColumnChnagedByToOrderStatusChanges < ActiveRecord::Migration[7.0]
  def change
    add_column :order_status_changes, :changed_by_id, :integer
    add_column :order_status_changes, :changed_by_type, :string
  end
end
