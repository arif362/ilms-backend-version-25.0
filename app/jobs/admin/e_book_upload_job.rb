# frozen_string_literal: true

module Admin
  class EBookUploadJob < ApplicationJob
    queue_as :default

    def perform(ebook)
      EBook.create!(ebook)
    end
  end
end
