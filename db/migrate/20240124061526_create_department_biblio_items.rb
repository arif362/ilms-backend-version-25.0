class CreateDepartmentBiblioItems < ActiveRecord::Migration[7.0]
  def change
    create_table :department_biblio_items do |t|
      t.references :goods_receipt
      t.references :publisher_biblio
      t.references :library
      t.references :po_line_item
      t.string :central_accession_no
      t.references :department_biblio_item_status, index: { name: 'index_dbis_on_dbi_status_id' }
      t.datetime :deleted_at
      t.integer 'updated_by_id'
      t.string 'updated_by_type'
      t.timestamps
    end
  end
end
