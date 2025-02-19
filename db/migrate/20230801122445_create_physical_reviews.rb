class CreatePhysicalReviews < ActiveRecord::Migration[7.0]
  def change
    create_table :physical_reviews do |t|
      t.integer :user_id
      t.integer :biblio_item_id
      t.text :review_body
      t.timestamps
    end
  end
end
