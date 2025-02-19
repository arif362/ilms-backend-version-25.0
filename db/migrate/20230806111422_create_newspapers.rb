class CreateNewspapers < ActiveRecord::Migration[7.0]
  def change
    create_table :newspapers do |t|
      t.string :name
      t.boolean :is_published, default: false
      t.integer :created_by
      t.integer :updated_by_id
      t.timestamps
    end
  end
end
