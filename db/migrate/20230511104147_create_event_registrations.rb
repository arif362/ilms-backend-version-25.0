class CreateEventRegistrations < ActiveRecord::Migration[7.0]
  def change
    create_table :event_registrations do |t|
      t.belongs_to :event_library
      t.belongs_to :user
      t.string :name, null: false
      t.string :phone_number, null: false
      t.string :email
      t.string :address
      t.integer :membership_category, default: 0
      t.integer :identity_type, default: 0
      t.string :identity_number, null: false
      t.timestamps
    end
  end
end
