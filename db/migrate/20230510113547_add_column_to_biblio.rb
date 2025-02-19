class AddColumnToBiblio < ActiveRecord::Migration[7.0]
  def change
    add_column :biblios, :search_count, :integer, default: 0
    add_column :biblios, :view_count, :integer, default: 0
    add_column :biblios, :borrow_count, :integer, default: 0
    add_column :biblios, :read_count, :integer, default: 0
    add_column :authors, :popular_count, :integer, default: 0
  end
end
