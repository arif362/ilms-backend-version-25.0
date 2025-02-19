class Thana < ApplicationRecord
  audited

  belongs_to :district
  has_one :library

  validates :name, :bn_name, presence: true
  validates_uniqueness_of :name, :bn_name, scope: :district_id
  scope :not_deleted, -> { where(is_deleted: false) }

end
