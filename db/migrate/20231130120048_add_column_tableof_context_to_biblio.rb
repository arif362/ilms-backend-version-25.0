class AddColumnTableofContextToBiblio < ActiveRecord::Migration[7.0]
  def change
    add_column :biblios, :table_of_context, :string
  end
end
