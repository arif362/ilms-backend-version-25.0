class ChangeDataTypesOfLmsReportJsonParams < ActiveRecord::Migration[7.0]
  def up
    change_column :lms_reports, :event_participants, :text
    change_column :lms_reports, :event_winners, :text
    change_column :lms_reports, :bind_paper_bangla, :text
    change_column :lms_reports, :bind_paper_english, :text
    change_column :lms_reports, :bind_magazine_bangla, :text
    change_column :lms_reports, :bind_magazine_english, :text
    change_column :lms_reports, :edited_fields_default_values, :text
  end

  def down
    change_column :lms_reports, :event_participants, :json
    change_column :lms_reports, :event_winners, :json
    change_column :lms_reports, :bind_paper_bangla, :json
    change_column :lms_reports, :bind_paper_english, :json
    change_column :lms_reports, :bind_magazine_bangla, :json
    change_column :lms_reports, :bind_magazine_english, :json
    change_column :lms_reports, :edited_fields_default_values, :json
  end
end
