class AddColumnsToLibraries < ActiveRecord::Migration[7.0]
  def change
    add_column :libraries, :description, :text
    add_column :libraries, :bn_description, :text
    add_column :libraries, :phone, :string
  end
end
