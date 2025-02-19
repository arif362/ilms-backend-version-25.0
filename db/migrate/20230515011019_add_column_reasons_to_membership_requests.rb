class AddColumnReasonsToMembershipRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :membership_requests, :notes, :text, array: true
  end
end
