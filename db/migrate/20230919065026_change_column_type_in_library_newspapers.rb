class ChangeColumnTypeInLibraryNewspapers < ActiveRecord::Migration[7.0]
  def change
    change_column :library_newspapers, :start_date, :datetime
    change_column :library_newspapers, :end_date, :datetime
  end
end
