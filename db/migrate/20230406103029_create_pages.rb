class CreatePages < ActiveRecord::Migration[7.0]
  def change
    create_table :pages do |t|
      t.string :title, null: false
      t.longtext :description, null: false
      t.string :bn_title, null: false
      t.string :slug, null: false
      t.longtext :bn_description, null: false
      t.boolean :is_active, default: true, null: false
      t.boolean :is_deletable, default: true, null: false

      t.timestamps
    end
  end
end
