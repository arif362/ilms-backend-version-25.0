# frozen_string_literal: true

class FaqCategory < ApplicationRecord
  has_many :faqs, dependent: :restrict_with_exception

  validates :title, :bn_title, presence: true, uniqueness: true
end
