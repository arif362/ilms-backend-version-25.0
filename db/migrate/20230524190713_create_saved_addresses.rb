class CreateSavedAddresses < ActiveRecord::Migration[7.0]
  def change
    create_table :saved_addresses do |t|
      t.string :name
      t.text :address
      t.references :user
      t.references :division
      t.references :district
      t.references :thana

      t.timestamps
    end
  end
end
