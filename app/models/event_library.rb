# frozen_string_literal: true

class EventLibrary < ApplicationRecord
  audited
  belongs_to :event
  belongs_to :library

  validates_uniqueness_of :library_id, scope: :event_id
end
