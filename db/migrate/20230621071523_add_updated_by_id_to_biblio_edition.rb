class AddUpdatedByIdToBiblioEdition < ActiveRecord::Migration[7.0]
  def up
    rename_column :biblio_editions, :created_by, :created_by_id
    change_column :biblio_editions, :created_by_id, :bigint
    add_column :biblio_editions, :updated_by_id, :bigint
    add_column :biblio_editions, :is_deleted, :boolean, default: false
    change_column :biblio_editions, :description, :longtext, limit: 4294967295
  end

  def down
    change_column :biblio_editions, :description, :text
  end
end
