class Cart < ApplicationRecord
  belongs_to :user
  belongs_to :library, optional: true
  has_many :cart_items, dependent: :destroy
end
