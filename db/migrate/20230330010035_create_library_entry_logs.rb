class CreateLibraryEntryLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :library_entry_logs do |t|
      t.references :entryable, polymorphic: true, null: false
      t.integer :library_id, null: false
      t.text :services, array: true
      t.string :name
      t.integer :gender
      t.integer :age
      t.string :email
      t.string :phone

      t.timestamps
    end
  end
end
