# frozen_string_literal: true

class EBook < ApplicationRecord
  require 'csv'

  validates :title, :book_url, presence: true, uniqueness: true
  enum book_type: { linked: 0, flip_book: 1 }
  scope :published, -> { where(is_published: true) }

  def self.import_ebooks(file)

    CSV.foreach(file[:tempfile].path, headers: true) do |ebook_hash|
      ebook = EBook.find_by(title: ebook_hash.fetch('title'))
      next if ebook.present?

      new_ebook = {}
      new_ebook[:title] = ebook_hash.fetch('title')
      new_ebook[:book_url] = ebook_hash.fetch('book_url')
      new_ebook[:author] = ebook_hash.fetch('author')
      new_ebook[:author_url] = ebook_hash.fetch('author_url')
      new_ebook[:year] = ebook_hash.fetch('year')
      new_ebook[:publisher] = ebook_hash.fetch('publisher')

      Admin::EBookUploadJob.perform_later(new_ebook)
    end
  end
end
