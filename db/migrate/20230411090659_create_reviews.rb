class CreateReviews < ActiveRecord::Migration[7.0]
  def change
    create_table :reviews do |t|
      t.string :text
      t.integer :status
      t.integer :rating, default: 0
      t.references :biblio
      t.references :user
      t.timestamps
    end
  end
end
