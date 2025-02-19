class CreateSecurityMoneys < ActiveRecord::Migration[7.0]
  def change
    create_table :security_moneys do |t|
      t.integer :user_id, null: false
      t.integer :amount, null: false
      t.integer :member_id, null: false
      t.integer :library_id
      t.integer :invoice_id
      t.integer :payment_method
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
