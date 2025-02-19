class CreateBiblioSubjectBiblios < ActiveRecord::Migration[7.0]
  def change
    create_table :biblio_subject_biblios do |t|
      t.belongs_to :biblio
      t.belongs_to :biblio_subject
      t.timestamps
    end
  end
end
