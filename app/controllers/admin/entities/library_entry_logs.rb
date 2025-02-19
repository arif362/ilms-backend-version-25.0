module Admin
  module Entities
    class LibraryEntryLogs < Grape::Entity
      expose :id
      expose :name
      expose :unique_id
      expose :phone
      expose :gender
      expose :age
      expose :library
      expose :services
      expose :entry_time
      expose :entry_date
      expose :services
      expose :entryable_type

      def entry_time
        object.created_at.strftime("%k:%M")
      end

      def entry_date
        object.created_at.strftime("%d of %B, %Y")
      end

      def unique_id
        object&.entryable&.unique_id
      end

      def library
        library = Library.find_by(id: object&.library_id)
        {
          "id": library.id,
          "library_code": library.code
        }
      end

      def name
        object.entryable&.registered_name
      end

      def gender
        object&.entryable&.gender
      end

      def dob
        object&.entryable&.dob
      end

      def phone
        object&.entryable&.phone
      end

    end
  end
end
