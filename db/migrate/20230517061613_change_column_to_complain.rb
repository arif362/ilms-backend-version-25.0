class ChangeColumnToComplain < ActiveRecord::Migration[7.0]
  def change
    remove_column :complains, :send_notification, :boolean, default: false
    remove_column :complains, :sent_email, :boolean, default: false
  end
end
