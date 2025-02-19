class CreateMembershipRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :membership_requests do |t|
      t.integer :user_id, null: false
      t.integer :request_type, default: 0
      t.integer :status, default: 0
      t.integer :request_detail_id
      t.bigint :invoice_id
      t.integer :payment_status, default: 0
      t.bigint :created_by_id
      t.bigint :updated_by_id

      t.timestamps
    end
  end
end
