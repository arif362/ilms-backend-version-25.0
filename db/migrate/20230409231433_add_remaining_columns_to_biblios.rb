class AddRemainingColumnsToBiblios < ActiveRecord::Migration[7.0]
  def change
    add_column :biblios, :corporate_name, :string
    rename_column :biblios, :subtitle, :remainder_of_title
    add_column :biblios, :statement_of_responsibility, :string
    add_column :biblios, :edition_statement, :string
    add_column :biblios, :place_of_publication, :string
    add_column :biblios, :date_of_publication, :string
    add_column :biblios, :extent, :string
    remove_column :biblios, :price
  end
end
