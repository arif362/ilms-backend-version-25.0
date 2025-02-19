# frozen_string_literal: true

class Faq < ApplicationRecord
  audited

  belongs_to :faq_category

  validates_presence_of :question, :bn_question, :answer, :bn_answer, :position
  validates :position, numericality: { greater_than: 0 }
  validates_uniqueness_of :position, :question, :bn_question, scope: :is_published, condition: -> { where(is_published: true) }
  scope :published, -> { where(is_published: true) }
end
