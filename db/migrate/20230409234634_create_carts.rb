class CreateCarts < ActiveRecord::Migration[7.0]
  def change
    create_table :carts do |t|
      t.references :user
      t.references :library
      t.decimal :total, precision: 10, scale: 4, default: 0

      t.timestamps
    end
  end
end
