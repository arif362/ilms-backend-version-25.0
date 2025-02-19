class RemovePaymentStatus < ActiveRecord::Migration[7.0]
  def change
    remove_column :membership_requests, :payment_status
  end
end
