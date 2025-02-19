class AddThreePsStatusToOrderStatuses < ActiveRecord::Migration[7.0]
  def change
    add_column :order_statuses, :three_ps_status, :string
  end
end
