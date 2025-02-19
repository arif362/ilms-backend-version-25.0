# frozen_string_literal: true

module Lms
  module Entities
    class BiblioItems < Grape::Entity
      expose :id
      expose :barcode
      expose :accession_no
      expose :biblio_item_type
      expose :full_call_number
      expose :note
      expose :copy_number
      expose :not_for_loan
      expose :date_accessioned
      expose :permanent_library_location_id
      expose :current_library_location_id
      expose :shelving_library_location_id
      expose :biblio_id
      expose :library_id
      expose :price
      expose :created_by_id
      expose :updated_by_id
    end
  end
end
