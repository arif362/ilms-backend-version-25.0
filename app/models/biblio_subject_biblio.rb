class BiblioSubjectBiblio < ApplicationRecord
  audited
  belongs_to :biblio
  belongs_to :biblio_subject
end
