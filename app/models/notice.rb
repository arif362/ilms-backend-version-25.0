class Notice < ApplicationRecord
  include SearchableEngBanglaTitle

  audited

  has_one_attached :document
  has_many :notifications, as: :notificationable, dependent: :destroy
  enum notice_type: { web_site: 0, library: 1 }

  validates_presence_of :title, :bn_title
  validates :document, blob: { content_type: 'application/pdf' }

  before_create :set_slug
  after_commit on: :create do
    Lms::LibrarianNoticeJob.perform_later(self) if library?
  end

  default_scope { where(is_deleted: false) }
  scope :published, -> { where(is_published: true) }

  def set_slug
    base_slug = title.to_s.parameterize
    existing_notice = Notice.find_by(slug: base_slug)

    return base_slug if existing_notice.nil?

    # If a notice with the same slug exists, append the next ID
    next_id = Notice.last.id + 1
    self.slug = "#{base_slug}-#{next_id}"
  end

  def document_file=(file)
    return if file.blank?

    document.attach(io: file[:tempfile],
                    filename: file[:filename],
                    content_type: file[:type])
  end
end
