class CreateCardStatusChanges < ActiveRecord::Migration[7.0]
  def change
    create_table :card_status_changes do |t|
      t.references :library_card
      t.references :card_status
      t.bigint :changed_by_id
      t.string :changed_by_type

      t.timestamps
    end
  end
end
