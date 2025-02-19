class CreateMemorandums < ActiveRecord::Migration[7.0]
  def change
    create_table :memorandums do |t|
      t.string :memorandum_no, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.string :tender_session, null: false
      t.date :work_order_date, null: false
      t.date :book_delivery_date, null: false
      t.integer :status, null: false

      t.timestamps

    end
  end
end
