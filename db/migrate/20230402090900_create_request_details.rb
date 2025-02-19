class CreateRequestDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :request_details do |t|
      t.string :full_name
      t.string :email
      t.string :phone
      t.integer :gender, default: 0
      t.date :dob
      t.string :mother_name
      t.string :father_Name
      t.boolean :status, default: true
      t.integer :identity_type, default: 0
      t.string :identity_number
      t.string :present_address
      t.string :permanent_address
      t.bigint :requested_by_id
      t.bigint :library_id, null: false
      t.string :profession
      t.string :institute_name
      t.integer :membership_category, default: 0
      t.bigint :created_by_id
      t.bigint :updated_by_id

      t.timestamps
    end
  end
end