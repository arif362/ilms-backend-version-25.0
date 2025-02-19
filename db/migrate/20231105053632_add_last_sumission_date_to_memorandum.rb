class AddLastSumissionDateToMemorandum < ActiveRecord::Migration[7.0]
  def change
    add_column :memorandums, :last_submission_date, :date
  end
end
