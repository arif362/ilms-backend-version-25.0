class CreateLibraryNewspapers < ActiveRecord::Migration[7.0]
  def change
    create_table :library_newspapers do |t|
      t.integer :library_id
      t.integer :newspaper_id
      t.integer :language
      t.string :start_date
      t.string :end_date
      t.boolean :is_continue, default: false
      t.integer :created_by
      t.integer :updated_by_id
      t.timestamps
    end
  end
end
