class AddColumnsToOrderStatuses < ActiveRecord::Migration[7.0]
  def change
    add_column :order_statuses, :status_key, :integer, null: false
    add_column :order_statuses, :lms_status, :string, null: false
  end
end
