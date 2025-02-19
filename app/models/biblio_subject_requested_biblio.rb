# frozen_string_literal: true

class BiblioSubjectRequestedBiblio < ApplicationRecord
  belongs_to :biblio_subject
  belongs_to :requested_biblio
end
