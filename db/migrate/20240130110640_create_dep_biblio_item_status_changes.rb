class CreateDepBiblioItemStatusChanges < ActiveRecord::Migration[7.0]
  def change
    create_table :dep_biblio_item_status_changes do |t|
      t.references :department_biblio_item, index: { name: 'index_dbis_on_dbi_id' }
      t.references :department_biblio_item_status, index: { name: 'index_dbis_changes_on_dbi_id'}
      t.integer 'changed_by_id'
      t.string 'changed_by_type'
      t.timestamps
    end
  end
end
