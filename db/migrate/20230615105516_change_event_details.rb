class ChangeEventDetails < ActiveRecord::Migration[7.0]
  def up
    change_column :events, :details, :longtext
    change_column :events, :bn_details, :longtext
  end

  def down
    change_column :events, :details, :longtext
    change_column :events, :bn_details, :longtext
  end
end
