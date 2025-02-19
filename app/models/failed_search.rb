# frozen_string_literal: true

class FailedSearch < ApplicationRecord
  validates_presence_of :keyword
end
