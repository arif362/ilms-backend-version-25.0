# frozen_string_literal: true

class OtherLibraryBiblio < ApplicationRecord
  belongs_to :trackable, polymorphic: true
  belongs_to :permanent_library, class_name: 'Library'
  belongs_to :current_library, class_name: 'Library'
  belongs_to :biblio_item
  belongs_to :biblio

  enum status: { pending: 0, returned: 1 }

  def self.add_other_library_biblio(trackable, receiver_library_id, sender_library_id, biblio_item)
    OtherLibraryBiblio.find_or_create_by!(trackable: trackable,
                                          permanent_library_id: receiver_library_id,
                                          current_library_id: sender_library_id,
                                          biblio_item:,
                                          biblio_id: biblio_item&.biblio&.id)
  end
end
