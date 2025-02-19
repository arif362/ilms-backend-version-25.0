class CreateFaqs < ActiveRecord::Migration[7.0]
  def change
    create_table :faqs do |t|
      t.bigint :faq_category_id
      t.bigint :created_by_id
      t.bigint :updated_by_id
      t.text :question
      t.text :bn_question
      t.text :answer
      t.text :bn_answer
      t.boolean :is_published, default: false
      t.integer :position, default: 1
      t.timestamps
    end
  end
end
