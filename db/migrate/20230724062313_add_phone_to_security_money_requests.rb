class AddPhoneToSecurityMoneyRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :security_money_requests, :phone, :string
  end
end
