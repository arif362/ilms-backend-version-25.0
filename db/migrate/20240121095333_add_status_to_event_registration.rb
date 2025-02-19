class AddStatusToEventRegistration < ActiveRecord::Migration[7.0]
  def change
    add_column :event_registrations, :status, :integer, default: 0
  end
end
