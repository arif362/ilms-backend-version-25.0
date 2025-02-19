class AddThanaAndDistrictIdToLibraryEntryLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :library_entry_logs, :thana_id, :bigint
    add_column :library_entry_logs, :district_id, :bigint
  end
end
