class CreateCirculationStatusChanges < ActiveRecord::Migration[7.0]
  def change
    create_table :circulation_status_changes do |t|
      t.references :circulation
      t.references :circulation_status
      t.bigint :created_by_id
      t.timestamps
    end
  end
end
