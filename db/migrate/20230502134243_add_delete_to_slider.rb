class AddDeleteToSlider < ActiveRecord::Migration[7.0]
  def change
    add_column :homepage_sliders, :is_deleted, :boolean, default: false
    add_column :banners, :is_deleted, :boolean, default: false
  end
end
