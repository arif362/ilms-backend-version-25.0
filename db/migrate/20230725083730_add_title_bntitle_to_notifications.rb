class AddTitleBntitleToNotifications < ActiveRecord::Migration[7.0]
  def change
    add_column :notifications, :title, :string
    add_column :notifications, :bn_title, :string
  end
end
