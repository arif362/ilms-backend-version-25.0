# frozen_string_literal: true

class Division < ApplicationRecord

  audited
  has_many :districts, dependent: :restrict_with_exception
  has_many :thanas, through: :districts

  validates :name, :bn_name, presence: true, uniqueness: true
  scope :not_deleted, -> { where(is_deleted: false) }
end
