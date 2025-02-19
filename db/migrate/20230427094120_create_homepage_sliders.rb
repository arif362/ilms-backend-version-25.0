class CreateHomepageSliders < ActiveRecord::Migration[7.0]
  def change
    create_table :homepage_sliders do |t|
      t.string :title
      t.boolean :is_visible, default: true
      t.string :link
      t.integer :serial_no
      t.timestamps
    end
  end
end
