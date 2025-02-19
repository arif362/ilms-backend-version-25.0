class InvoicesPayment < ApplicationRecord
  belongs_to :invoice
  belongs_to :payment
end
