# frozen_string_literal: true
class ChangeMonthDatatimeDateInIls < ActiveRecord::Migration[7.0]
  def up
    change_column :ils_reports, :month, :date
  end

  def down
    change_column :ils_reports, :month, :datetime
  end
end
