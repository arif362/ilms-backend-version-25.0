class AddCategoryToNewspaper < ActiveRecord::Migration[7.0]
  def change
    add_column :newspapers, :category, :integer
  end
end
