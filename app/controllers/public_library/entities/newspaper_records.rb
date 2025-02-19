# frozen_string_literal: true

module PublicLibrary
  module Entities
    class NewspaperRecords < Grape::Entity
      expose :id
      expose :language
      expose :start_date
      expose :end_date
      expose :newspaper
      expose :library
      expose :is_continue
      expose :is_binding

      def newspaper

        paper = object.newspaper

        {
          id: paper.id,
          name: paper.name,
          bn_name: paper.bn_name,
          slug: paper.slug,
          category: paper.category,
          language: paper.language,
        }
      end

      def library
        library = object&.library
        librarian = library&.staffs.where(is_library_head: true).last

        {
          id: library&.id,
          name: library&.name,
          code: library&.code,
          librarian_name: librarian&.name,
          librarian_phone: librarian&.phone,
          librarian_designation: librarian&.designation,
          librarian_email: librarian&.email
        }
      end
    end
  end
end
