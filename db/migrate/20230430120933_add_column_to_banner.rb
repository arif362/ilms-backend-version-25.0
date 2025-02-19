class AddColumnToBanner < ActiveRecord::Migration[7.0]
  def change
    add_column :banners, :bn_title, :string, null: false
  end
end
