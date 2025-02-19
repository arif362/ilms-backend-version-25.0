# frozen_string_literal: true

class AuthorRequestedBiblio < ApplicationRecord
  belongs_to :author
  belongs_to :requested_biblio
end
