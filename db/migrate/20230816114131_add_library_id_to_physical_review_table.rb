class AddLibraryIdToPhysicalReviewTable < ActiveRecord::Migration[7.0]
  def change
    add_column :physical_reviews, :library_id, :integer
  end
end
