class CreateThirdPartyUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :third_party_users do |t|
      t.string :email, null: false
      t.string :password_hash
      t.string :phone
      t.string :company
      t.integer :created_by
      t.integer :updated_by
      t.boolean :is_active, default: true

      t.timestamps
    end
  end
end
