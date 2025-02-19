class CreateBanners < ActiveRecord::Migration[7.0]
  def change
    create_table :banners do |t|
      t.string :title
      t.boolean :is_visible, default: true
      t.string :slug
      t.timestamps
    end
  end
end
