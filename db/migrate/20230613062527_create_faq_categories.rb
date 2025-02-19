class CreateFaqCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :faq_categories do |t|
      t.bigint :created_by_id
      t.bigint :updated_by_id
      t.string :title
      t.string :bn_title
      t.timestamps
    end
  end
end
