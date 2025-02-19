# frozen_string_literal: true

module Lms
  module Entities
    class BiblioSubjectBiblios < Grape::Entity
      expose :id
      expose :biblio_subject_id
    end
  end
end
