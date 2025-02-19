class CreateBiblioStatuses < ActiveRecord::Migration[7.0]
  def change
    create_table :biblio_statuses do |t|
      t.integer :status_type
      t.integer :created_by

      t.timestamps
    end
  end
end
