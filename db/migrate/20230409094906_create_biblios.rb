class CreateBiblios < ActiveRecord::Migration[7.0]
  def change
    create_table :biblios do |t|
      t.references :author
      t.string :title
      t.string :subtitle
      t.date :copyright_date
      t.references :item_type
      t.string :isbn, limit: 20
      t.string :original_cataloging_agency, limit: 25
      t.string :calaloging_language, limit: 40
      t.string :ddc_edition_number, limit: 40
      t.string :ddc_classification_number, limit: 40
      t.string :ddc_item_number, limit: 40
      t.references :biblio_edition
      t.references :biblio_publication
      t.string :physical_details
      t.string :other_physical_details
      t.string :dimentions, limit: 35
      t.text :series_statement_title, limit: 100
      t.text :series_statement_volume, limit: 15
      t.string :issn, limit: 15
      t.string :series_statement, limit: 35
      t.text :general_note
      t.text :bibliography_note
      t.text :contents_note
      t.string :topical_term, limit: 50
      t.string :full_call_number, limit: 35
      t.decimal :price, precision: 10, scale: 4
      t.integer :pages, default: 0
      t.string :age_restriction, limit: 35
      t.timestamps
    end
  end
end
