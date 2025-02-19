class RemoveFieldsFromMemorandums < ActiveRecord::Migration[7.0]
  def change
    remove_column :memorandums, :book_delivery_date, :date
    remove_column :memorandums, :work_order_date, :date
    remove_column :memorandums, :status, :integer
  end
end
