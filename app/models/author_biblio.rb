# frozen_string_literal: true

class AuthorBiblio < ApplicationRecord
  belongs_to :biblio
  belongs_to :author
end
