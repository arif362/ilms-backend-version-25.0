class AddMemberIdToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :member_id, :integer
  end
end
