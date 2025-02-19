class CardStatusChange < ApplicationRecord
  belongs_to :card_status
  belongs_to :library_card
  belongs_to :changed_by, polymorphic: true, optional: true

  default_scope -> { order(id: :asc) }
end
