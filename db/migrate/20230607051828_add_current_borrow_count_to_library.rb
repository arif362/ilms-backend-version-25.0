class AddCurrentBorrowCountToLibrary < ActiveRecord::Migration[7.0]
  def change
    add_column :libraries, :current_borrow_count, :integer, default: 0
  end
end
