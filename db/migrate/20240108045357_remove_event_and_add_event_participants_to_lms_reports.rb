# frozen_string_literal: true

class RemoveEventAndAddEventParticipantsToLmsReports < ActiveRecord::Migration[7.0]
  def change
    # Remove 'event' field
    remove_column :lms_reports, :event if column_exists?(:lms_reports, :event, :json)
    add_column :lms_reports, :event_participants, :json
    add_column :lms_reports, :event_winners, :json
    # Change specified text fields to JSON
    remove_column :lms_reports, :bind_paper_bangla, :text
    remove_column :lms_reports, :bind_paper_english, :text
    remove_column :lms_reports, :bind_magazine_bangla, :text
    remove_column :lms_reports, :bind_magazine_english, :text
    add_column :lms_reports, :bind_paper_bangla, :json
    add_column :lms_reports, :bind_paper_english, :json
    add_column :lms_reports, :bind_magazine_bangla, :json
    add_column :lms_reports, :bind_magazine_english, :json
  end
end
