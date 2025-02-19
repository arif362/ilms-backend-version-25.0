module Lms
  module Entities
    class NewspaperRecords < Grape::Entity
      expose :id
      expose :library_id
      expose :newspaper
      expose :start_date
      expose :end_date
      expose :is_continue
      expose :language
      expose :is_binding

      def newspaper
        newspaper = object&.newspaper
        {
          id: newspaper&.id,
          name: newspaper&.name,
          category: newspaper&.category,
          language: newspaper&.language
        }
      end
    end
  end
end
