class AddExpiredAtFieldToLibraryCard < ActiveRecord::Migration[7.0]
  def change
    add_column :library_cards, :expired_at, :datetime
  end
end
