class CreatePreferences < ActiveRecord::Migration[7.0]
  def change
    create_table :preferences do |t|
      t.integer :max_borrow, default: 2, null: false

      t.timestamps
    end
  end
end
