class CreateBiblioSubjects < ActiveRecord::Migration[7.0]
  def change
    create_table :biblio_subjects do |t|
      t.string :personal_name
      t.string :bn_personal_name
      t.string :corporate_name
      t.string :topical_name
      t.string :geographic_name
      t.boolean :is_deleted, default: false
      t.integer :created_by
      t.integer :updated_by
      t.integer :deleted_by
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
