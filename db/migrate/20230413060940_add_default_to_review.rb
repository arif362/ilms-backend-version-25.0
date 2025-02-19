class AddDefaultToReview < ActiveRecord::Migration[7.0]
  def change
    change_column_default :reviews, :status, from: nil, to: 0
  end
end
