class CreateIlsReports < ActiveRecord::Migration[7.0]
  def change
    create_table :ils_reports do |t|
      t.integer :biblio_bangla_new_item, default: 0
      t.integer :biblio_english_new_item, default: 0
      t.integer :biblio_other_new_item, default: 0
      t.integer :biblio_new_item_total, default: 0
      t.integer :biblio_bangla_last_month_total, default: 0
      t.integer :biblio_english_last_month_total, default: 0
      t.integer :biblio_other_last_month_total, default: 0
      t.integer :biblio_last_month_total, default: 0
      t.integer :biblio_bangla_total_item, default: 0
      t.integer :biblio_english_total_item, default: 0
      t.integer :biblio_other_total_item, default: 0
      t.integer :biblio_total_item_total, default: 0
      t.integer :biblio_bangla_current_item, default: 0
      t.integer :biblio_english_current_item, default: 0
      t.integer :biblio_other_current_item, default: 0
      t.integer :biblio_current_item_total, default: 0
      t.integer :papers_bangla, default: 0
      t.integer :papers_english, default: 0
      t.integer :magazine_bangla, default: 0
      t.integer :magazine_english, default: 0
      t.integer :bind_paper_bangla, default: 0
      t.integer :bind_paper_english, default: 0
      t.integer :bind_magazine_bangla, default: 0
      t.integer :bind_magazine_english, default: 0
      t.integer :book_reader_total, default: 0
      t.integer :paper_magazine_reader_total, default: 0
      t.integer :book_paper_magazine_reader_total, default: 0
      t.integer :book_paper_magazine_reader_male_total, default: 0
      t.integer :book_paper_magazine_reader_female_total, default: 0
      t.integer :book_paper_magazine_reader_child_total, default: 0
      t.integer :book_paper_magazine_reader_other_total, default: 0
      t.integer :reference_question_male, default: 0
      t.integer :reference_question_female, default: 0
      t.integer :reference_question_child, default: 0
      t.integer :reference_question_total, default: 0
      t.integer :mobile_library_reader_male, default: 0
      t.integer :mobile_library_reader_female, default: 0
      t.integer :mobile_library_reader_child, default: 0
      t.integer :mobile_library_reader_other, default: 0
      t.integer :mobile_library_reader_total, default: 0
      t.json :event
      t.integer :lending_system_total, default: 0
      t.integer :lost_total_lost, default: 0
      t.integer :lost_total_lost_amount, default: 0
      t.integer :discarded_lost_book_total_lost, default: 0
      t.integer :discarded_lost_book_total_lost_amount, default: 0
      t.integer :burn_book_total, default: 0
      t.integer :burn_book_total_amount, default: 0
      t.integer :pruned_book_total, default: 0
      t.integer :pruned_book_total_amount, default: 0
      t.integer :discarded_pruned_book_total, default: 0
      t.integer :discarded_pruned_book_total_amount, default: 0

      t.timestamps
    end
  end
end
