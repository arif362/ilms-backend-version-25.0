module Admin
  module Entities
    class LmsReportList < Grape::Entity
      expose :id
      expose :library
      expose :total_reader
      expose :librarian
      expose :month, as: :submission_date

      def library
        library = object&.library
        {
          id: library&.id,
          name: library&.name,
          code: library&.code
        }
      end
      def librarian
        librarian = object&.library&.staffs&.where(is_library_head: true)&.first
        {
          id: librarian&.id,
          name: librarian&.name,
          email: librarian&.email,
          phone: librarian&.phone
        }
      end

      def total_reader
        object.mobile_library_reader_male + object.mobile_library_reader_female + object.mobile_library_reader_child + object.mobile_library_reader_other + object.book_reader_male + object.book_reader_female + object.book_reader_child + object.book_reader_other + object.paper_magazine_reader_male + object.paper_magazine_reader_female + object.paper_magazine_reader_child + object.paper_magazine_reader_other
      end

    end
  end
end
