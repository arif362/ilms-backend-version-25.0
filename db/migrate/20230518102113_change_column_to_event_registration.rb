class ChangeColumnToEventRegistration < ActiveRecord::Migration[7.0]
  def change
    remove_reference :event_registrations, :event_library
    add_reference :event_registrations, :event
    add_reference :event_registrations, :library
  end
end
