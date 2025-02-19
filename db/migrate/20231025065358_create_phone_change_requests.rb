class CreatePhoneChangeRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :phone_change_requests do |t|
      t.string :phone
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
