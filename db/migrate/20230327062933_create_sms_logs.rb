class CreateSmsLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :sms_logs do |t|
      t.integer :sms_type
      t.json :api_request
      t.json :api_response
      t.string :content, null: false
      t.string :phone, null: false, index: true

      t.timestamps
    end
  end
end
