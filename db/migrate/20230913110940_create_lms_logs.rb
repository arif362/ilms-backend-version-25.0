class CreateLmsLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :lms_logs do |t|
      t.json :api_response
      t.string :user_able_type
      t.integer :user_able_id
      t.boolean :status
      t.json :api_request

      t.timestamps
    end
  end
end
