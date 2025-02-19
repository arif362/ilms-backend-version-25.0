class CreateFailedSearches < ActiveRecord::Migration[7.0]
  def change
    create_table :failed_searches do |t|
      t.string :keyword
      t.integer :search_count, default: 1
      t.timestamps
    end
  end
end
