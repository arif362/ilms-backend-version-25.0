class CreateThanas < ActiveRecord::Migration[7.0]
  def change
    create_table :thanas do |t|
      t.string :name
      t.string :bn_name
      t.references :district
      t.timestamps
    end
  end
end
