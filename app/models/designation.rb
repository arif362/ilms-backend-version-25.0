class Designation < ApplicationRecord
  audited
  # Associations
  has_many :staffs, dependent: :restrict_with_exception

  # validations
  validates :title, presence: true, uniqueness: true
end
