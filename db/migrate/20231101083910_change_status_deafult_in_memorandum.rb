class ChangeStatusDeafultInMemorandum < ActiveRecord::Migration[7.0]
  def change
    change_column :memorandums, :status, :integer, default: 0, null: false
  end
end
