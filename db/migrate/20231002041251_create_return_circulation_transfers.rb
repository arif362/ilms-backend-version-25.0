class CreateReturnCirculationTransfers < ActiveRecord::Migration[7.0]
  def change
    create_table :return_circulation_transfers do |t|
      t.bigint :biblio_item_id
      t.bigint :user_id
      t.bigint :circulation_id
      t.bigint :sender_library_id
      t.bigint :receiver_library_id
      t.integer :status, default: 0
      t.bigint :updated_by_id
      t.string :updated_by_type
      t.bigint :created_by_id
      t.string :created_by_type
      t.timestamps
    end
  end
end
