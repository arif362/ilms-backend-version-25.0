class CreateSecurityMoneyRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :security_money_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.references :library, null: false, foreign_key: true
      t.references :security_money, null: false, foreign_key: true
      t.integer :status, default: 0
      t.integer :payment_method, default: 0
      t.integer :amount, default: 0
      t.string :note
      t.integer :last_updated_by_id

      t.timestamps
    end
  end
end
