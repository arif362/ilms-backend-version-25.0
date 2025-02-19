# frozen_string_literal: true

module PublicLibrary
  module Entities
    class AuthorBiblios < Grape::Entity
      expose :author, merge: true, using: PublicLibrary::Entities::Authors
    end
  end
end
