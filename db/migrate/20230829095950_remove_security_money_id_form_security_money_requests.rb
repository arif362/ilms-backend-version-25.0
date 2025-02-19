class RemoveSecurityMoneyIdFormSecurityMoneyRequests < ActiveRecord::Migration[7.0]
  def change
    remove_column :security_money_requests, :security_money_id
  end
end
