class AddColumnAvgRatingToBiblios < ActiveRecord::Migration[7.0]
  def change
    add_column :biblios, :average_rating, :float, default: 0, null: false
    add_column :biblios, :total_reviews, :integer, default: 0, null: false
  end
end
