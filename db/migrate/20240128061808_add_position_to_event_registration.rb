class AddPositionToEventRegistration < ActiveRecord::Migration[7.0]
  def change
    add_column :event_registrations, :winner_position, :string
  end
end
