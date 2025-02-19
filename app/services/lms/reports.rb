# frozen_string_literal: true

module Lms
  class Reports
    include Interactor
    include PublicLibrary::Helpers::ImageHelpers

    delegate :ils_report_current, to: :context
    def call
      new_ils_report
    end

    def new_ils_report


      ils_report_current.biblio_bangla_new_item = ils_report_current.lms_reports.sum(:biblio_bangla_new_item)
      ils_report_current.biblio_english_new_item = ils_report_current.lms_reports.sum(:biblio_english_new_item)
      ils_report_current.biblio_other_new_item = ils_report_current.lms_reports.sum(:biblio_other_new_item)
      ils_report_current.biblio_new_item_total = ils_report_current.biblio_bangla_new_item + ils_report_current.biblio_english_new_item + ils_report_current.biblio_other_new_item
      ils_report_current.biblio_bangla_last_month_total = ils_report_current.lms_reports.sum(:biblio_bangla_last_month_total)
      ils_report_current.biblio_english_last_month_total = ils_report_current.lms_reports.sum(:biblio_english_last_month_total)
      ils_report_current.biblio_other_last_month_total = ils_report_current.lms_reports.sum(:biblio_other_last_month_total)
      ils_report_current.biblio_last_month_total = ils_report_current.biblio_bangla_last_month_total + ils_report_current.biblio_english_last_month_total + ils_report_current.biblio_other_last_month_total
      ils_report_current.biblio_bangla_total_item = ils_report_current.lms_reports.sum(:biblio_bangla_total_item)
      ils_report_current.biblio_english_total_item = ils_report_current.lms_reports.sum(:biblio_english_total_item)
      ils_report_current.biblio_other_total_item = ils_report_current.lms_reports.sum(:biblio_other_total_item)
      ils_report_current.biblio_total_item_total = ils_report_current.biblio_bangla_total_item + ils_report_current.biblio_english_total_item + ils_report_current.biblio_other_total_item
      ils_report_current.biblio_bangla_current_item = ils_report_current.lms_reports.sum(:biblio_bangla_current_item)
      ils_report_current.biblio_english_current_item = ils_report_current.lms_reports.sum(:biblio_english_current_item)
      ils_report_current.biblio_other_current_item = ils_report_current.lms_reports.sum(:biblio_other_current_item)
      ils_report_current.biblio_current_item_total = ils_report_current.biblio_bangla_current_item + ils_report_current.biblio_english_current_item + ils_report_current.biblio_other_current_item
      ils_report_current.papers_bangla = ils_report_current.lms_reports.map(&:papers_bangla).compact.flatten.uniq
      ils_report_current.papers_english = ils_report_current.lms_reports.map(&:papers_english).compact.flatten.uniq
      ils_report_current.magazine_bangla = ils_report_current.lms_reports.map(&:magazine_bangla).compact.flatten.uniq
      ils_report_current.magazine_english = ils_report_current.lms_reports.map(&:magazine_english).compact.flatten.uniq
      ils_report_current.event ||= '[]'
      event_data = []
      ils_report_current.lms_reports.each do |report|
        report.event_participants.each do |event_participant|
          event_data << event_participant
        end
      end

      ils_report_current.event = event_data.to_json
      ils_report_current.book_reader_total = ils_report_current.lms_reports.sum(:book_reader_male) + ils_report_current.lms_reports.sum(:book_reader_female) + ils_report_current.lms_reports.sum(:book_reader_child) + ils_report_current.lms_reports.sum(:book_reader_other)
      ils_report_current.paper_magazine_reader_total = ils_report_current.lms_reports.sum(:paper_magazine_reader_male) + ils_report_current.lms_reports.sum(:paper_magazine_reader_female) + ils_report_current.lms_reports.sum(:paper_magazine_reader_child) + ils_report_current.lms_reports.sum(:paper_magazine_reader_other)
      ils_report_current.book_paper_magazine_reader_male_total = ils_report_current.lms_reports.sum(:book_reader_male) + ils_report_current.lms_reports.sum(:paper_magazine_reader_male)
      ils_report_current.book_paper_magazine_reader_female_total = ils_report_current.lms_reports.sum(:book_reader_female) + ils_report_current.lms_reports.sum(:paper_magazine_reader_female)
      ils_report_current.book_paper_magazine_reader_child_total = ils_report_current.lms_reports.sum(:book_reader_child) + ils_report_current.lms_reports.sum(:paper_magazine_reader_child)
      ils_report_current.book_paper_magazine_reader_other_total = ils_report_current.lms_reports.sum(:book_reader_other) + ils_report_current.lms_reports.sum(:paper_magazine_reader_other)
      ils_report_current.book_paper_magazine_reader_total = ils_report_current.book_paper_magazine_reader_male_total + ils_report_current.book_paper_magazine_reader_female_total + ils_report_current.book_paper_magazine_reader_child_total + ils_report_current.book_paper_magazine_reader_other_total
      ils_report_current.reference_question_male = ils_report_current.lms_reports.sum(:reference_question_male)
      ils_report_current.reference_question_female = ils_report_current.lms_reports.sum(:reference_question_female)
      ils_report_current.reference_question_child = ils_report_current.lms_reports.sum(:reference_question_child)
      ils_report_current.reference_question_total = ils_report_current.reference_question_male + ils_report_current.reference_question_female + ils_report_current.reference_question_child
      ils_report_current.mobile_library_reader_male = ils_report_current.lms_reports.sum(:mobile_library_reader_male)
      ils_report_current.mobile_library_reader_female = ils_report_current.lms_reports.sum(:mobile_library_reader_female)
      ils_report_current.mobile_library_reader_child = ils_report_current.lms_reports.sum(:mobile_library_reader_child)
      ils_report_current.mobile_library_reader_other = ils_report_current.lms_reports.sum(:mobile_library_reader_other)
      ils_report_current.mobile_library_reader_total = ils_report_current.mobile_library_reader_male + ils_report_current.mobile_library_reader_female + ils_report_current.mobile_library_reader_child + ils_report_current.mobile_library_reader_other
      ils_report_current.lending_system_total = ils_report_current.lms_reports.sum(:lending_system_male) + ils_report_current.lms_reports.sum(:lending_system_female) + ils_report_current.lms_reports.sum(:lending_system_child)
      ils_report_current.lending_system_issue_book = ils_report_current.lms_reports.sum(:lending_system_issue_book)
      ils_report_current.lending_system_issue_book_return = ils_report_current.lms_reports.sum(:lending_system_issue_book_return)
      ils_report_current.lost_total_lost = ils_report_current.lms_reports.sum(:lost_total_lost)
      ils_report_current.lost_total_lost_amount = ils_report_current.lms_reports.sum(:lost_amount)
      ils_report_current.discarded_lost_book_total_lost = ils_report_current.lms_reports.sum(:discarded_lost_book_total_lost)
      ils_report_current.discarded_lost_book_total_lost_amount = ils_report_current.lms_reports.sum(:discarded_lost_book_total_lost)
      ils_report_current.burn_book_total = ils_report_current.lms_reports.sum(:burn_discarded_lost_book_total_burn) - ils_report_current.lms_reports.sum(:discarded_lost_book_total_lost)
      ils_report_current.burn_book_total_amount = ils_report_current.lms_reports.sum(:burn_discarded_lost_book_amount) - ils_report_current.lms_reports.sum(:discarded_lost_amount)
      ils_report_current.pruned_book_total = ils_report_current.lms_reports.sum(:pruned_book_total)
      ils_report_current.pruned_book_total_amount = ils_report_current.lms_reports.sum(:pruned_book_amount)
      ils_report_current.discarded_pruned_book_total = ils_report_current.lms_reports.sum(:discarded_pruned_book_total)
      ils_report_current.discarded_pruned_book_total_amount = ils_report_current.lms_reports.sum(:discarded_pruned_book_amount)
      ils_report_current.printer_wb_working = ils_report_current.lms_reports.sum(:printer_bw_active)
      ils_report_current.printer_wb_not_working = ils_report_current.lms_reports.sum(:printer_bw_inactive)
      ils_report_current.printer_c_working = ils_report_current.lms_reports.sum(:printer_color_active)
      ils_report_current.printer_c_not_working = ils_report_current.lms_reports.sum(:printer_color_inactive)
      ils_report_current.cctv_working_working = ils_report_current.lms_reports.sum(:cc_camera_active)
      ils_report_current.cctv_not_working = ils_report_current.lms_reports.sum(:cc_camera_inactive)
      ils_report_current.photo_copy_working = ils_report_current.lms_reports.sum(:photocopier_active)
      ils_report_current.photo_copy_not_working = ils_report_current.lms_reports.sum(:photocopier_inactive)
      ils_report_current.registered_private_library = ils_report_current.lms_reports.sum(:non_govt_library)

      ils_report_current.save
    end
  end
end
