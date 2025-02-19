class AddPageTypeToBanner < ActiveRecord::Migration[7.0]
  def change
    add_reference :banners, :page_type, null: false
    add_column :banners, :position, :integer, default: 1
  end
end
