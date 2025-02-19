# frozen_string_literal: true

class PageType < ApplicationRecord
  has_many :banners, dependent: :restrict_with_exception
  validates :title, presence: true, uniqueness: true
end
