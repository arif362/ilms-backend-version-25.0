class CreateStaffs < ActiveRecord::Migration[7.0]
  def change
    create_table :staffs do |t|
      t.string :name
      t.string :email
      t.string :password
      t.string :phone_number
      t.boolean :is_active, default: true
      t.integer :admin_type
      t.references :library, null: true
      t.references :role
      t.references :designation
      t.bigint :created_by_id
      t.bigint :updated_by_id
      t.timestamps
    end
  end
end
