class ChangeColumnTypeInAnnouncements < ActiveRecord::Migration[7.0]
  def change
    change_column :announcements, :description, :text
    change_column :announcements, :bn_description, :text
  end
end
