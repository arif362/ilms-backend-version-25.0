class BiblioWishlist < ApplicationRecord
  belongs_to :biblio
  belongs_to :user
end
