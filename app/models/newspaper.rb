# frozen_string_literal: true

class Newspaper < ApplicationRecord
  include NewspaperSearchable
  validates :name, uniqueness: true, presence: true
  validates_uniqueness_of :slug
  has_many :library_newspapers, dependent: :restrict_with_exception

  enum category: { daily: 0, magazine: 1 }
  enum language: { english: 0, bangla: 1 }

  scope :published, -> { where(is_published: true) }

  before_create :set_slug
  after_commit on: :create do
    Lms::NewspaperJob.perform_later(self)
  end
  def set_slug
    self.slug = name.to_s.parameterize.present? ? name.to_s.parameterize : name.to_s
  end
end
