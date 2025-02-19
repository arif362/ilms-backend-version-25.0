class CreateAuthorizationKeys < ActiveRecord::Migration[7.0]
  def change
    create_table :authorization_keys do |t|
      t.string :token
      t.datetime :expiry
      t.references :authable, polymorphic: true

      t.timestamps
    end
  end
end
