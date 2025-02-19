class CreateAuthorBiblios < ActiveRecord::Migration[7.0]
  def change
    create_table :author_biblios do |t|
      t.references :biblio, null: false
      t.references :author, null: false
      t.boolean :is_primary, default: false
      t.timestamps
    end
  end
end
