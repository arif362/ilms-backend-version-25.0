class AddColumnsToReturnItems < ActiveRecord::Migration[7.0]
  def change
    add_column :return_items, :late_days, :integer, default: 0
    add_column :return_items, :fine_sub_total, :integer, default: 0
  end
end
