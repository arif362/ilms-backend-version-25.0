class CreateOtps < ActiveRecord::Migration[7.0]
  def change
    create_table :otps do |t|
      t.string :code, null: false
      t.string :otp_able_type
      t.integer :otp_able_id
      t.datetime :expiry
      t.datetime :send_interval_time
      t.boolean :is_used, default: false
      t.boolean :is_otp_verified, default: false
      t.json :api_request
      t.json :api_response
      t.string :phone, null: false, index: true

      t.timestamps
    end
  end
end
