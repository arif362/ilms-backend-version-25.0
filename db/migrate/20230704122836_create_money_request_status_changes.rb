class CreateMoneyRequestStatusChanges < ActiveRecord::Migration[7.0]
  def change
    create_table :money_request_status_changes do |t|
      t.references :security_money_request, null: false, foreign_key: true
      t.integer :created_by_id
      t.integer :status

      t.timestamps
    end
  end
end
