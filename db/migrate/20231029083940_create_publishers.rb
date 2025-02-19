class CreatePublishers < ActiveRecord::Migration[7.0]
  def change
    create_table :publishers do |t|
      t.string :publication_name
      t.string :name
      t.string :author_name
      t.string :address
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
