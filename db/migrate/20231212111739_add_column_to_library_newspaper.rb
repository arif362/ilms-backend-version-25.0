class AddColumnToLibraryNewspaper < ActiveRecord::Migration[7.0]
  def change
    add_column :library_newspapers, :is_binding, :boolean, null: true
  end
end
