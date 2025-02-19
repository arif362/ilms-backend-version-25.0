# frozen_string_literal: true

module Admin
  module QueryParams
    module LmsReportParams
      extend ::Grape::API::Helpers

      params :lms_report_update_params do
        requires :working_days, type: Integer, allow_blank: false
        requires :biblio_bangla_last_month_total, type: Integer, allow_blank: false
        requires :biblio_bangla_new_item, type: Integer, allow_blank: false
        requires :biblio_bangla_total_item, type: Integer, allow_blank: false
        requires :biblio_bangla_current_item, type: Integer, allow_blank: false
        requires :biblio_english_last_month_total, type: Integer, allow_blank: false
        requires :biblio_english_new_item, type: Integer, allow_blank: false
        requires :biblio_english_total_item, type: Integer, allow_blank: false
        requires :biblio_english_current_item, type: Integer, allow_blank: false
        requires :biblio_other_last_month_total, type: Integer, allow_blank: false
        requires :biblio_other_new_item, type: Integer, allow_blank: false
        requires :biblio_other_total_item, type: Integer, allow_blank: false
        requires :biblio_other_current_item, type: Integer, allow_blank: false
        optional :bind_paper_bangla, allow_blank: false, type: Array do
          requires :newspaper_ref_id, allow_blank: false, type: Integer
          requires :info, allow_blank: false, type: String
        end
        optional :bind_paper_english, allow_blank: false, type: Array do
          requires :newspaper_ref_id, allow_blank: false, type: Integer
          requires :info, allow_blank: false, type: String
        end
        optional :bind_magazine_bangla, allow_blank: false, type: Array do
          requires :newspaper_ref_id, allow_blank: false, type: Integer
          requires :info, allow_blank: false, type: String
        end
        optional :bind_magazine_english, allow_blank: false, type: Array do
          requires :newspaper_ref_id, allow_blank: false, type: Integer
          requires :info, allow_blank: false, type: String
        end
        requires :biblio_bangla_lost_total, type: Integer, allow_blank: false
        requires :biblio_bangla_discarded_total, type: Integer, allow_blank: false
        requires :biblio_english_lost_total, type: Integer, allow_blank: false
        requires :biblio_english_discarded_total, type: Integer, allow_blank: false
        requires :biblio_other_lost_total, type: Integer, allow_blank: false
        requires :biblio_other_discarded_total, type: Integer, allow_blank: false
        requires :land_record, type: Boolean, allow_blank: false
        requires :library_building, type: String, allow_blank: false
        requires :library_area, type: Float, allow_blank: false
        requires :library_room, type: Integer, allow_blank: false
        requires :library_land_comment, type: String, allow_blank: false
        requires :computer_active, type: Integer, allow_blank: false
        requires :computer_inactive, type: Integer, allow_blank: false
        requires :computer_server_active, type: Integer, allow_blank: false
        requires :computer_server_inactive, type: Integer, allow_blank: false
        requires :printer_bw_active, type: Integer, allow_blank: false
        requires :printer_bw_inactive, type: Integer, allow_blank: false
        requires :printer_color_active, type: Integer, allow_blank: false
        requires :printer_color_inactive, type: Integer, allow_blank: false
        requires :scanner_active, type: Integer, allow_blank: false
        requires :scanner_inactive, type: Integer, allow_blank: false
        requires :cc_camera_active, type: Integer, allow_blank: false
        requires :cc_camera_inactive, type: Integer, allow_blank: false
        requires :photocopier_active, type: Integer, allow_blank: false
        requires :photocopier_inactive, type: Integer, allow_blank: false
        optional :device_remarks, type: String, allow_blank: false
        requires :office_telephone_exist, type: Boolean, allow_blank: false
        requires :quantity_of_office_telephone, type: Integer, allow_blank: false
        requires :accommodation_telephone_exist, type: Boolean, allow_blank: false
        requires :quantity_of_accommodation_telephone, type: Integer, allow_blank: false
        requires :fax_exist, type: Boolean, allow_blank: false
        requires :quantity_of_fax, type: Integer, allow_blank: false
        requires :transport_exist, type: Boolean, allow_blank: false
        requires :quantity_of_transport, type: Integer, allow_blank: false
        optional :connection_remarks, type: String, allow_blank: false
        requires :photocopy_use_office, type: Boolean, allow_blank: false
        requires :photocopy_use_user, type: Boolean, allow_blank: false
        requires :internet_connect, type: Boolean, allow_blank: false
        requires :internet_speed, type: String, allow_blank: false
        requires :solar_system, type: Boolean, allow_blank: false
        requires :solar_system_active, type: Integer, allow_blank: false
        requires :solar_system_inactive, type: Integer, allow_blank: false
        requires :ict_equipment_comment, type: String, allow_blank: false
        requires :non_govt_library, type: Integer, allow_blank: false
        requires :mobile_library_reader_male, type: Integer, allow_blank: false
        requires :mobile_library_reader_female, type: Integer, allow_blank: false
        requires :mobile_library_reader_child, type: Integer, allow_blank: false
        requires :mobile_library_reader_other, type: Integer, allow_blank: false
        requires :book_reader_male, type: Integer, allow_blank: false
        requires :book_reader_female, type: Integer, allow_blank: false
        requires :book_reader_child, type: Integer, allow_blank: false
        requires :book_reader_other, type: Integer, allow_blank: false
        requires :paper_magazine_reader_male, type: Integer, allow_blank: false
        requires :paper_magazine_reader_female, type: Integer, allow_blank: false
        requires :paper_magazine_reader_child, type: Integer, allow_blank: false
        requires :paper_magazine_reader_other, type: Integer, allow_blank: false
        requires :reference_question_male, type: Integer, allow_blank: false
        requires :reference_question_female, type: Integer, allow_blank: false
        requires :reference_question_child, type: Integer, allow_blank: false
        optional :event_current_month, type: String, allow_blank: false
        optional :event_upcoming_2month, type: String, allow_blank: false
        optional :event_participants, allow_blank: false, type: Array do
          requires :event_name, allow_blank: false, type: String
          optional :remarks, allow_blank: false, type: String
          requires :participants, allow_blank: false, type: Array do
            requires :competition_name, allow_blank: false, type: String
            requires :group_a_male, allow_blank: false, type: Integer
            requires :group_a_female, allow_blank: false, type: Integer
            requires :group_b_male, allow_blank: false, type: Integer
            requires :group_b_female, allow_blank: false, type: Integer
            requires :group_c_male, allow_blank: false, type: Integer
            requires :group_c_female, allow_blank: false, type: Integer
            requires :group_d_male, allow_blank: false, type: Integer
            requires :group_d_female, allow_blank: false, type: Integer
            requires :group_e_male, allow_blank: false, type: Integer
            requires :group_e_female, allow_blank: false, type: Integer
          end
        end
        optional :event_winners, allow_blank: false, type: Array do
          requires :event_name, allow_blank: false, type: String
          optional :remarks, allow_blank: false, type: String
          requires :winners, allow_blank: false, type: Array do
            requires :competition_name, allow_blank: false, type: String
            requires :group_a_male, allow_blank: false, type: Integer
            requires :group_a_female, allow_blank: false, type: Integer
            requires :group_b_male, allow_blank: false, type: Integer
            requires :group_b_female, allow_blank: false, type: Integer
            requires :group_c_male, allow_blank: false, type: Integer
            requires :group_c_female, allow_blank: false, type: Integer
            requires :group_d_male, allow_blank: false, type: Integer
            requires :group_d_female, allow_blank: false, type: Integer
            requires :group_e_male, allow_blank: false, type: Integer
            requires :group_e_female, allow_blank: false, type: Integer
          end
        end
        requires :inspection_inspector_name, type: String, allow_blank: false
        requires :inspection_date, type: DateTime, allow_blank: false
        requires :inspection_purpose, type: String, allow_blank: false
        requires :inspection_notes, type: String, allow_blank: false
        requires :lending_system_male, type: Integer, allow_blank: false
        requires :lending_system_female, type: Integer, allow_blank: false
        requires :lending_system_child, type: Integer, allow_blank: false
        requires :lending_system_issue_book, type: Integer, allow_blank: false
        requires :lending_system_issue_book_return, type: Integer, allow_blank: false
        optional :lost_start_end_year, type: String, allow_blank: false
        requires :lost_total_lost, type: Integer, allow_blank: false
        optional :lost_total_lost_in_text, type: String, allow_blank: false
        requires :lost_amount, type: Float, allow_blank: false
        optional :discarded_lost_book_start_end_year, type: String, allow_blank: false
        requires :discarded_lost_book_total_lost, type: Integer, allow_blank: false
        optional :discarded_lost_lost_total_lost_in_text, type: String, allow_blank: false
        requires :discarded_lost_amount, type: Float, allow_blank: false
        requires :burn_discarded_lost_book_total_burn, type: Integer, allow_blank: false
        requires :burn_discarded_lost_book_amount, type: Float, allow_blank: false
        optional :pruned_book_start_end_year, type: String, allow_blank: false
        requires :pruned_book_total, type: Float, allow_blank: false
        optional :pruned_book_total_in_text, type: String, allow_blank: false
        requires :pruned_book_amount, type: Float, allow_blank: false
        optional :discarded_pruned_book_start_end_year, type: String, allow_blank: false
        requires :discarded_pruned_book_total, type: Float, allow_blank: false
        optional :discarded_pruned_book_total_in_text, type: String, allow_blank: false
        requires :discarded_pruned_book_amount, type: Float, allow_blank: false
        optional :development_project, allow_blank: false, type: Array do
          requires :project_name, type: String, allow_blank: false
          requires :cost, type: Integer, allow_blank: false
          requires :duration, type: String, allow_blank: false
          requires :allocation_amount, type: Integer, allow_blank: false
          optional :remarks, type: String, allow_blank: false
        end
        optional :edited_fields_default_values, type: JSON, allow_blank: false
      end
    end
  end
end
