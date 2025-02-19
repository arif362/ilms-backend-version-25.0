# frozen_string_literal: true

module PublicLibrary
  module Entities
    class BiblioFilter < Grape::Entity
      expose :authors, using: PublicLibrary::Entities::Authors
      expose :subjects, using: PublicLibrary::Entities::BiblioSubject
      expose :publications, using: PublicLibrary::Entities::BiblioPublications
    end
  end
end
