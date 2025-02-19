class CreateIlsLmsReports < ActiveRecord::Migration[7.0]
  def change
    create_table :ils_lms_reports do |t|
      t.references :lms_report, null: false, foreign_key: true
      t.references :ils_report, null: false, foreign_key: true

      t.timestamps
    end
  end
end
