class UserSuggestion < ApplicationRecord
  belongs_to :user
  belongs_to :biblio, optional: true
  belongs_to :author, optional: true
  belongs_to :biblio_subject, optional: true
end

