class ReturnItem < ApplicationRecord
  belongs_to :return_order
  belongs_to :biblio
  belongs_to :biblio_item
  belongs_to :circulation
  has_many :invoices, dependent: :restrict_with_exception
end
