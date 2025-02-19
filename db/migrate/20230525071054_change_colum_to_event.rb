class ChangeColumToEvent < ActiveRecord::Migration[7.0]
  def change
    remove_column :events, :is_all_library, :boolean, default: false
    add_column :events, :registration_fields, :string
    remove_column :event_registrations, :name, :string, from: { null: false }, to: { null: true }
    remove_column :event_registrations, :phone_number, :string, from: { null: false }, to: { null: true }
    remove_column :event_registrations, :identity_number, :string, from: { null: false }, to: { null: true }
    add_column :event_registrations, :name, :string
    add_column :event_registrations, :phone, :string
    add_column :event_registrations, :identity_number, :string
  end
end
