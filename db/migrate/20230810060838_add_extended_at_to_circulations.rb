class AddExtendedAtToCirculations < ActiveRecord::Migration[7.0]
  def change
    add_column :circulations, :extended_at, :datetime
    add_column :circulations, :late_days, :integer
  end
end
