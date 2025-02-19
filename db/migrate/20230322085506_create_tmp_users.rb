class CreateTmpUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :tmp_users do |t|
      t.string :full_name
      t.string :email
      t.string :phone
      t.string :otp
      t.boolean :is_otp_verified, default: false
      t.datetime :dob
      t.integer :gender

      t.timestamps
    end
  end
end
