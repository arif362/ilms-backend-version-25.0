class CreateReturnCirculationStatusChanges < ActiveRecord::Migration[7.0]
  def change
    create_table :return_circulation_status_changes do |t|
      t.bigint :return_circulation_transfer_id, null: false
      t.integer :return_circulation_status_id, null: false
      t.bigint :changed_by_id
      t.string :changed_by_type
      t.timestamps
    end
  end
end
