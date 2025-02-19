class CreateUserQrCodes < ActiveRecord::Migration[7.0]
  def change
    create_table :user_qr_codes do |t|
      t.bigint :user_id
      t.string :qr_code
      t.datetime :expired_at
      t.bigint :library_id
      t.text :services
      t.timestamps
    end
  end
end
