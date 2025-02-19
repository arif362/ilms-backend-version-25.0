module Lms
  module Entities
    class LibraryEntryLogs < Grape::Entity
      expose :id
      expose :entryable
      expose :library_id
      expose :library
      expose :services
      expose :name
      expose :email
      expose :phone
      expose :gender
      expose :age
      expose :thana
      expose :district
    end
  end
end
