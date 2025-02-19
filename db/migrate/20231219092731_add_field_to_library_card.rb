class AddFieldToLibraryCard < ActiveRecord::Migration[7.0]
  def change
    add_column :library_cards, :is_expired, :boolean
  end
end
