class DepBiblioItemStatusChange < ApplicationRecord
  belongs_to :department_biblio_item
  belongs_to :department_biblio_item_status
  belongs_to :changed_by, polymorphic: true, optional: true
end
