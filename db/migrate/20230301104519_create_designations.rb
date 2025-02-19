class CreateDesignations < ActiveRecord::Migration[7.0]
  def change
    create_table :designations do |t|
      t.string :title
      t.string :bn_title
      t.bigint :created_by_id
      t.bigint :updated_by_id
      t.timestamps
    end
  end
end
