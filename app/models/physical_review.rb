class PhysicalReview < ApplicationRecord
  has_one_attached :book_image

  belongs_to :user
  belongs_to :biblio_item, optional: true
  belongs_to :library

  after_commit on: :create do
    Lms::PhysicalReviewJob.perform_later(self, 'created')
  end

  def book_image_file=(file)
    return if file.blank?

    book_image.attach(io: file[:tempfile],
                      filename: file[:filename],
                      content_type: file[:type])
  end
end
