# frozen_string_literal: true

class District < ApplicationRecord
  audited
  belongs_to :division
  has_many :thanas, dependent: :restrict_with_exception
  has_many :libraries, through: :thanas, dependent: :restrict_with_exception

  validates :name, :bn_name, presence: true, uniqueness: true
  scope :not_deleted, -> { where(is_deleted: false) }

  def library_from_district(thana)
    libraries.find_by(name: thana&.name)
  end
end
