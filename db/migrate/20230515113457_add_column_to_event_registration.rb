class AddColumnToEventRegistration < ActiveRecord::Migration[7.0]
  def change
    add_column :event_registrations, :father_name, :string
    add_column :event_registrations, :mother_name, :string
    add_column :event_registrations, :profession, :string
  end
end
