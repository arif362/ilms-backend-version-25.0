class CreateMembers < ActiveRecord::Migration[7.0]
  def change
    create_table :members do |t|
      t.references :user
      t.references :library
      t.references :membership_request
      t.string :mother_name
      t.string :father_Name
      t.integer :identity_type, default: 0
      t.integer :identity_number
      t.string :present_address
      t.string :permanent_address
      t.string :profession
      t.string :institute_name
      t.boolean :is_active, default: false
      t.integer :membership_category, default: 0
      t.integer :created_by_id
      t.integer :updated_by_id
      t.datetime :expire_date
      t.datetime :activated_at
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
