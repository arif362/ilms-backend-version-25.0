module Lms
  module Entities
    class LmsReports < Grape::Entity
      expose :id
      expose :library_id
      expose :month
      expose :working_days
      expose :biblio_bangla_last_month_total
      expose :biblio_bangla_new_item
      expose :biblio_bangla_total_item
      expose :biblio_bangla_current_item
      expose :biblio_english_last_month_total
      expose :biblio_english_new_item
      expose :biblio_english_total_item
      expose :biblio_english_current_item
      expose :biblio_other_last_month_total
      expose :biblio_other_new_item
      expose :biblio_other_total_item
      expose :biblio_other_current_item
      expose :biblio_bangla_lost_total
      expose :biblio_bangla_discarded_total
      expose :biblio_english_lost_total
      expose :biblio_english_discarded_total
      expose :biblio_other_lost_total
      expose :biblio_other_discarded_total
      expose :papers_bangla, using: Lms::Entities::NewspaperDropdowns
      expose :papers_english, using: Lms::Entities::NewspaperDropdowns
      expose :magazine_bangla, using: Lms::Entities::NewspaperDropdowns
      expose :magazine_english, using: Lms::Entities::NewspaperDropdowns
      expose :bind_paper_bangla
      expose :bind_paper_english
      expose :bind_magazine_bangla
      expose :bind_magazine_english
      expose :land_record
      expose :library_building
      expose :library_area
      expose :library_room
      expose :library_land_comment
      expose :computer_active
      expose :computer_inactive
      expose :computer_server_active
      expose :computer_server_inactive
      expose :printer_bw_active
      expose :printer_bw_inactive
      expose :printer_color_active
      expose :printer_color_inactive
      expose :scanner_active
      expose :scanner_inactive
      expose :cc_camera_active
      expose :cc_camera_inactive
      expose :photocopier_active
      expose :photocopier_inactive
      expose :device_remarks
      expose :office_telephone_exist
      expose :quantity_of_office_telephone
      expose :accommodation_telephone_exist
      expose :quantity_of_accommodation_telephone
      expose :fax_exist
      expose :quantity_of_fax
      expose :transport_exist
      expose :quantity_of_transport
      expose :connection_remarks
      expose :photocopy_use_office
      expose :photocopy_use_user
      expose :internet_connect
      expose :internet_speed
      expose :solar_system
      expose :solar_system_active
      expose :solar_system_inactive
      expose :ict_equipment_comment
      expose :non_govt_library
      expose :mobile_library_reader_male
      expose :mobile_library_reader_female
      expose :mobile_library_reader_child
      expose :mobile_library_reader_other
      expose :book_reader_male
      expose :book_reader_female
      expose :book_reader_child
      expose :book_reader_other
      expose :paper_magazine_reader_male
      expose :paper_magazine_reader_female
      expose :paper_magazine_reader_child
      expose :paper_magazine_reader_other
      expose :reference_question_male
      expose :reference_question_female
      expose :reference_question_child
      expose :event_current_month
      expose :event_upcoming_2month
      expose :event_participants
      expose :event_winners
      expose :inspection_inspector_name
      expose :inspection_date
      expose :inspection_purpose
      expose :inspection_notes
      expose :lending_system_male
      expose :lending_system_female
      expose :lending_system_child
      expose :lending_system_issue_book
      expose :lending_system_issue_book_return
      expose :lost_start_end_year
      expose :lost_total_lost
      expose :lost_total_lost_in_text
      expose :lost_amount
      expose :discarded_lost_book_start_end_year
      expose :discarded_lost_book_total_lost
      expose :discarded_lost_lost_total_lost_in_text
      expose :discarded_lost_amount
      expose :burn_discarded_lost_book_total_burn
      expose :burn_discarded_lost_book_amount
      expose :pruned_book_start_end_year
      expose :pruned_book_total
      expose :pruned_book_total_in_text
      expose :pruned_book_amount
      expose :discarded_pruned_book_start_end_year
      expose :discarded_pruned_book_total
      expose :discarded_pruned_book_total_in_text
      expose :discarded_pruned_book_amount
      expose :development_project
      expose :staffs, using: Lms::Entities::Staffs
      expose :present_main_staffs, using: Lms::Entities::Staffs
      expose :edited_fields_default_values

      def present_main_staffs
        Staff.active.where(id: object.present_main_staff_ids)
      end

      def staffs
        Staff.active.where(id: object.present_main_staff_ids)
      end

      def papers_bangla
        Newspaper.where(id: object.papers_bangla, language: 'bangla')
      end

      def papers_english
        Newspaper.where(id: object.papers_english, language: 'english')
      end

      def magazine_bangla
        Newspaper.where(id: object.magazine_bangla, language: 'bangla')
      end

      def magazine_english
        Newspaper.where(id: object.magazine_english, language: 'english')
      end
    end
  end
end
