class CreateAccountDeletionRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :account_deletion_requests do |t|
      t.integer :user_id
      t.integer :status, default: 0
      t.text :reason
      t.integer :updated_by_id
      t.timestamps
    end
  end
end
