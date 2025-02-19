class CreateDistricts < ActiveRecord::Migration[7.0]
  def change
    create_table :districts do |t|
      t.string :name
      t.string :bn_name
      t.references :division
      t.timestamps
    end
  end
end
