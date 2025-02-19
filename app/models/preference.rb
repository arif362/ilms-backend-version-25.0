class Preference < ApplicationRecord
  validates :max_borrow, presence: true, numericality: { greater_than: 0 }
end
