class LtoLineItem < ApplicationRecord
  belongs_to :library_transfer_order
  belongs_to :biblio
  belongs_to :biblio_item, optional: true
end
