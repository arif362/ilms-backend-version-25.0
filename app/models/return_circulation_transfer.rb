class ReturnCirculationTransfer < ApplicationRecord
  belongs_to :circulation
  belongs_to :user
  belongs_to :biblio_item
  belongs_to :return_circulation_status
  belongs_to :created_by, polymorphic: true, optional: true
  belongs_to :updated_by, polymorphic: true, optional: true
  has_many :return_circulation_status_changes
  has_one :other_library_biblio, as: :trackable

  after_save :create_return_circulation_status_change, if: :return_circulation_status_id_previously_changed?
  after_create :add_other_library_biblio
  after_save :update_other_library_biblio, if: -> { return_circulation_status.delivered? }

  def create_return_circulation_status_change
    changed_by = updated_by.present? ? updated_by : created_by
    return_circulation_status_changes.find_or_create_by!(return_circulation_status_id: return_circulation_status.id,
                                                         changed_by:)
  end

  def add_other_library_biblio
    OtherLibraryBiblio.add_other_library_biblio(self, receiver_library_id, sender_library_id, biblio_item)
  end

  def update_other_library_biblio
    other_library_biblios.update!(status: OtherLibraryBiblio.statuses[:returned])
  end
end
