class AddCreatedByInSecuryMoneyRequest < ActiveRecord::Migration[7.0]
  def change
    add_column :security_money_requests, :created_by_type, :string
    add_column :security_money_requests, :created_by_id, :bigint
    add_column :security_money_requests, :updated_by_type, :string
    add_column :security_money_requests, :updated_by_id, :bigint
  end
end
