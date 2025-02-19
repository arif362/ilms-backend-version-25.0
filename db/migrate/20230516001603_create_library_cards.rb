class CreateLibraryCards < ActiveRecord::Migration[7.0]
  def change
    create_table :library_cards do |t|
      t.references :member
      t.integer :issued_library_id
      t.string :name
      t.datetime :issue_date
      t.datetime :expire_date
      t.integer :membership_category
      t.string :barcode, index: true
      t.string :recipient_name
      t.string :recipient_phone
      t.integer :address_type
      t.integer :division_id
      t.integer :district_id
      t.integer :thana_id
      t.integer :card_status_id
      t.integer :delivery_type, default: 0
      t.boolean :is_active, default: true
      t.boolean :is_lost, default: false
      t.boolean :is_damaged, default: false
      t.text :note

      t.timestamps
    end
  end
end
