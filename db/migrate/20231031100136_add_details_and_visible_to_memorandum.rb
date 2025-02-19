class AddDetailsAndVisibleToMemorandum < ActiveRecord::Migration[7.0]
  def change
    add_column :memorandums, :memorandum_details, :string
    add_column :memorandums, :is_visible, :boolean, default: true
  end
end
