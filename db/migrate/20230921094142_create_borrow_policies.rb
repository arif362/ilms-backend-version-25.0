class CreateBorrowPolicies < ActiveRecord::Migration[7.0]
  def change
    create_table :borrow_policies do |t|
      t.integer :item_type_id
      t.integer :category, default: 0
      t.text :note
      t.integer :checkout_allowed, default: 0
      t.integer :fine_changing_interval, default: 0
      t.integer :overdue, default: 0
      t.boolean :is_renewal_allowed, default: false
      t.integer :renewal_period, default: 0
      t.integer :renewal_times, default: 0
      t.boolean :is_automatic_renewal, default: false
      t.integer :max_renewal_day, default: 0
      t.integer :hold_allowed_daily, default: 0
      t.integer :hold_allowed_total, default: 0
      t.integer :fine_discount, default: 0
      t.integer :status, default: 0
      t.integer :not_loanable, default: 0
      t.integer :created_by_id
      t.integer :updated_by_id
      t.boolean :is_deleted, default: false
      t.timestamps
    end
  end
end
