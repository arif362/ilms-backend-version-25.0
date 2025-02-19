class AddCreatedByAndUpdatedByIdInEventRegistrations < ActiveRecord::Migration[7.0]
  def change
    add_column :event_registrations, :created_by_id, :integer
    add_column :event_registrations, :updated_by_id, :integer
    add_column :event_registrations, :rejection_note, :string
    add_column :event_registrations, :is_winner, :boolean, default: false
  end
end
