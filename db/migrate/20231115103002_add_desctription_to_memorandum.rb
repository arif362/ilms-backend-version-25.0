class AddDesctriptionToMemorandum < ActiveRecord::Migration[7.0]
  def change
    add_column :memorandums, :description, :text
  end
end
