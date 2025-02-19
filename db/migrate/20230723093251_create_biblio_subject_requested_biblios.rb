class CreateBiblioSubjectRequestedBiblios < ActiveRecord::Migration[7.0]
  def change
    create_table :biblio_subject_requested_biblios do |t|
      t.bigint :requested_biblio_id
      t.bigint :biblio_subject_id
      t.timestamps
    end
  end
end
