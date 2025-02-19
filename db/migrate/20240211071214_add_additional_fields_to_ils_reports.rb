class AddAdditionalFieldsToIlsReports < ActiveRecord::Migration[7.0]
  def change
    add_column :ils_reports, :printer_wb_working, :integer, default: 0
    add_column :ils_reports, :printer_wb_not_working, :integer, default: 0
    add_column :ils_reports, :printer_c_working, :integer, default: 0
    add_column :ils_reports, :printer_c_not_working, :integer, default: 0
    add_column :ils_reports, :cctv_working_working, :integer, default: 0
    add_column :ils_reports, :cctv_not_working, :integer, default: 0
    add_column :ils_reports, :photo_copy_working, :integer, default: 0
    add_column :ils_reports, :photo_copy_not_working, :integer, default: 0
    add_column :ils_reports, :registered_private_library, :integer, default: 0
    add_column :ils_reports, :robi_cafe, :integer, default: 0
    add_column :ils_reports, :library_internet_user, :integer, default: 0
    add_column :ils_reports, :library_computers, :integer, default: 0
    add_column :ils_reports, :lending_system_issue_book, :integer, default: 0
    add_column :ils_reports, :lending_system_issue_book_return, :integer, default: 0
    add_column :ils_reports, :month, :datetime
  end
end
