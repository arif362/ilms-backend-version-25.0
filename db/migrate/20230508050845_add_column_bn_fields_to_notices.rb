class AddColumnBnFieldsToNotices < ActiveRecord::Migration[7.0]
  def change
    add_column :notices, :bn_title, :string
    add_column :notices, :bn_description, :text
  end
end
