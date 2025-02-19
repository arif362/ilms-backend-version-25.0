class AddCompetitionNameAndParticipateGroupToEventRegistrations < ActiveRecord::Migration[7.0]
  def change
    add_column :event_registrations, :competition_name, :string
    add_column :event_registrations, :participate_group, :integer
  end
end
