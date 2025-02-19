# frozen_string_literal: true

module Admin
  module Entities
    class LibraryCurrentBorrowList < Grape::Entity

      expose :id
      expose :name
      expose :code
      expose :current_borrow_count
    end
  end
end
