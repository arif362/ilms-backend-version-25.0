class CreateEventLibraries < ActiveRecord::Migration[7.0]
  def change
    create_table :event_libraries do |t|
      t.belongs_to :library
      t.belongs_to :event
      t.integer :total_registered, default: 0
      t.timestamps
    end
  end
end
