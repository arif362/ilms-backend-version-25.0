class ChangeDefaultOfEvent < ActiveRecord::Migration[7.0]
  def change
    change_column_default :events, :is_published, from: true, to: false
  end
end
