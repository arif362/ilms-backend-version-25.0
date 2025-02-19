class ChangeDataTypeOfPapersBanglaInIlsReport < ActiveRecord::Migration[7.0]
  def up
    remove_column :ils_reports, :papers_bangla, :integer, default: 0
    remove_column :ils_reports, :papers_english, :integer, default: 0
    remove_column :ils_reports, :magazine_bangla, :integer, default: 0
    remove_column :ils_reports, :magazine_english, :integer, default: 0
    add_column :ils_reports, :papers_bangla, :text
    add_column :ils_reports, :papers_english, :text
    add_column :ils_reports, :magazine_bangla, :text
    add_column :ils_reports, :magazine_english, :text
  end

  def down
    remove_column :ils_reports, :papers_bangla, :text
    remove_column :ils_reports, :papers_english, :text
    remove_column :ils_reports, :magazine_bangla, :text
    remove_column :ils_reports, :magazine_english, :text
    add_column :ils_reports, :papers_bangla, :integer, default: 0
    add_column :ils_reports, :papers_english, :integer, default: 0
    add_column :ils_reports, :magazine_bangla, :integer, default: 0
    add_column :ils_reports, :magazine_english, :integer, default: 0
  end
end
