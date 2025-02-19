class Complain < ApplicationRecord
  audited
  belongs_to :user, optional: true
  belongs_to :library, optional: true
  has_many :notifications, as: :notificationable, dependent: :destroy

  has_many_attached :images do |image|
    image.variant :small, resize_to_limit: [295, 190]
    image.variant :large, resize_to_limit: [610, 400]
  end

  enum complain_type: { book_issue: 0, payment_issue: 1, library_issue: 2, delivery_issue: 3, others: 4 }
  enum action_type: { open: 0, reopen: 1, resolved: 2, inprogress: 3, closed: 4 }
  scope :not_deleted, -> { where(is_deleted: false) }

  validates :complain_type, :description, presence: true
  validates :images, blob: { content_type: %w[image/jpg image/jpeg image/png image/webp video/mp4 video/mkv video/avi video/mpeg-4 video/wmv video/webm], size_range: 1..50.megabytes }


  def images_file=(files)
    return if files.blank?

    img_arr = []
    files.each do |file|
      file_hash = {
        io: file[:tempfile],
        filename: file[:filename],
        content_type: file[:type]
      }
      img_arr << file_hash
    end
    self.images = img_arr
  end
end
