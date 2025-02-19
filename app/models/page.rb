class Page < ApplicationRecord
  # Associations

  has_one_attached :image do |attachable|
    attachable.variant :banner, resize_to_limit: [1440, 500]
  end

  # Validations
  validates :title, :bn_title, presence: true, uniqueness: true
  validates_uniqueness_of :slug
  validates :image, blob: { content_type: %w[image/jpg image/jpeg image/png image/webp], size_range: 1..3.megabytes }

  # Scope
  scope :active, -> { where(is_active: true) }
  scope :deletable, -> { where(is_deletable: true) }

  before_create :set_slug

  # Methods
  def image_file=(file)
    return if file.blank?

    image.attach(io: file[:tempfile],
                 filename: file[:filename],
                 content_type: file[:type])
  end

  def set_slug
    self.slug = title.to_s.parameterize
  end
end
