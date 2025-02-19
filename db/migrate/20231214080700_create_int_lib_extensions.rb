class CreateIntLibExtensions < ActiveRecord::Migration[7.0]
  def change
    create_table :int_lib_extensions do |t|
      t.bigint :library_transfer_order_id
      t.bigint :sender_library_id
      t.bigint :receiver_library_id
      t.datetime :extend_end_date
      t.integer :status, default: 0
      t.bigint :created_by_id
      t.string :created_by_type
      t.bigint :updated_by_id
      t.string :updated_by_type
      t.timestamps
    end
  end
end
