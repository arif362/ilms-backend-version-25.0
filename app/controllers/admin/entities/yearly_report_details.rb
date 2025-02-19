# frozen_string_literal: true

module Admin
  module Entities
    class YearlyReportDetails < Grape::Entity
      expose :id
      expose :current_time
      expose :biblio_bangla_new_item
      expose :biblio_english_new_item
      expose :biblio_other_new_item
      expose :biblio_new_item_total
      expose :biblio_bangla_last_month_total
      expose :biblio_english_last_month_total
      expose :biblio_other_last_month_total
      expose :biblio_last_month_total
      expose :biblio_bangla_total_item
      expose :biblio_english_total_item
      expose :biblio_other_total_item
      expose :biblio_total_item_total
      expose :biblio_bangla_current_item
      expose :biblio_english_current_item
      expose :biblio_other_current_item
      expose :biblio_current_item_total
      expose :papers_bangla_unique
      expose :papers_bangla_count
      expose :papers_english_unique
      expose :papers_english_count
      expose :magazine_bangla_unique
      expose :magazine_bangla_count
      expose :magazine_english_unique
      expose :magazine_english_count
      expose :bind_paper_bangla
      expose :bind_paper_english
      expose :bind_magazine_bangla
      expose :bind_magazine_english
      expose :book_reader_total
      expose :paper_magazine_reader_total
      expose :book_paper_magazine_reader_total
      expose :book_paper_magazine_reader_male_total
      expose :book_paper_magazine_reader_female_total
      expose :book_paper_magazine_reader_child_total
      expose :book_paper_magazine_reader_other_total
      expose :reference_question_male
      expose :reference_question_female
      expose :reference_question_child
      expose :reference_question_total
      expose :mobile_library_reader_male
      expose :mobile_library_reader_female
      expose :mobile_library_reader_child
      expose :mobile_library_reader_other
      expose :mobile_library_reader_total
      expose :event
      expose :lending_system_total
      expose :lost_total_lost
      expose :lost_total_lost_amount
      expose :discarded_lost_book_total_lost
      expose :discarded_lost_book_total_lost_amount
      expose :burn_book_total
      expose :burn_book_total_amount
      expose :pruned_book_total
      expose :pruned_book_total_amount
      expose :discarded_pruned_book_total
      expose :discarded_pruned_book_total_amount
      expose :created_at
      expose :updated_at
      expose :printer_wb_working
      expose :printer_wb_not_working
      expose :printer_c_working
      expose :printer_c_not_working
      expose :cctv_working_working
      expose :cctv_not_working
      expose :photo_copy_working
      expose :photo_copy_not_working
      expose :registered_private_library
      expose :library_computers
      expose :lending_system_issue_book
      expose :lending_system_issue_book_return
      expose :month


      def papers_bangla_unique
        object.papers_bangla.length
      end

      def papers_english_unique
        object.papers_english.length
      end

      def magazine_bangla_unique
        object.magazine_bangla.length
      end

      def magazine_english_unique
        object.magazine_english.length
      end

      def papers_bangla_count
        count = 0
        object.papers_bangla.each do |x|
          count += LibraryNewspaper.where("MONTH(`created_at`) = ?", object.month.month).where(newspaper_id: x).count
        end
        count
      end

      def papers_english_count
        count = 0
        object.papers_english.each do |x|
          count += LibraryNewspaper.where("MONTH(`created_at`) = ?", object.month.month).where(newspaper_id: x).count
        end
        count
      end

      def magazine_bangla_count
        count = 0
        object.magazine_bangla.each do |x|
          count += LibraryNewspaper.where("MONTH(`created_at`) = ?", object.month.month).where(newspaper_id: x).count
        end
        count
      end

      def magazine_english_count
        count = 0
        object.magazine_english.each do |x|
          count += LibraryNewspaper.where("MONTH(`created_at`) = ?", object.month.month).where(newspaper_id: x).count
        end
        count
      end

      def event
        events = JSON.parse(object.event)
        events.each do |event|
          event['participants']&.each do |participant|
            participant['male_total'] = participant.select { |key, _| key.end_with?('_male') }.values.sum
            participant['female_total'] = participant.select { |key, _| key.end_with?('_female') }.values.sum
          end
        end
        events
      end

      def current_time
        DateTime.current
      end
    end
  end
end
