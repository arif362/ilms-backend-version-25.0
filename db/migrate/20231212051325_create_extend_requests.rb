class CreateExtendRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :extend_requests do |t|
      t.bigint :library_id
      t.bigint :circulation_id
      t.integer :status, default: 0
      t.string :reason
      t.bigint :member_id
      t.bigint :order_id
      t.bigint :created_by_id
      t.string :created_by_type
      t.bigint :updated_by_id
      t.string :updated_by_type
      t.timestamps
    end
  end
end
