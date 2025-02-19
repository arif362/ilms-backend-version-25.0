class CreateAuthorRequestedBiblios < ActiveRecord::Migration[7.0]
  def change
    create_table :author_requested_biblios do |t|
      t.bigint :requested_biblio_id
      t.bigint :author_id
      t.timestamps
    end
  end
end
