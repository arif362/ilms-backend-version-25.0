class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :full_name
      t.string :email
      t.string :phone
      t.datetime :dob
      t.integer :tmp_id
      t.integer :gender
      t.string :password_hash
      t.string :user_code
      t.boolean :is_otp_verified, default: false
      t.boolean :is_active, default: false
      t.datetime :deleted_at
      t.bigint :created_by_id
      t.bigint :updated_by_id

      t.timestamps
    end
  end
end
