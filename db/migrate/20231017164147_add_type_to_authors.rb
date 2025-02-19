class AddTypeToAuthors < ActiveRecord::Migration[7.0]
  def change
    add_column :authors, :type, :string
  end
end
