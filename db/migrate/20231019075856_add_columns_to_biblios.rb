class AddColumnsToBiblios < ActiveRecord::Migration[7.0]
  def change
    add_column :biblios, :sub_title, :string
  end
end
