class CreateCirculations < ActiveRecord::Migration[7.0]
  def change
    create_table :circulations do |t|
      t.references :library
      t.references :biblio_item
      t.references :member
      t.references :circulation_status
      t.date :return_at
      t.date :returned_at
      t.timestamps
    end
  end
end
