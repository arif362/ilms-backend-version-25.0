class Biblio < ApplicationRecord
  audited
  include BiblioSearchable

  belongs_to :biblio_edition, optional: true
  belongs_to :biblio_publication, optional: true
  belongs_to :item_type
  belongs_to :biblio_classification_source, optional: true
  has_many :biblio_items, dependent: :restrict_with_exception
  has_many :biblio_libraries, dependent: :restrict_with_exception
  has_many :reviews, dependent: :restrict_with_exception
  has_many :biblio_wishlists
  has_many :biblio_subject_biblios, dependent: :restrict_with_exception
  has_many :biblio_subjects, through: :biblio_subject_biblios
  has_many :author_biblios, dependent: :restrict_with_exception
  has_many :authors, through: :author_biblios
  has_many :rebind_biblios, dependent: :restrict_with_exception
  has_many :other_library_biblios, dependent: :restrict_with_exception
  has_many :lto_line_items, dependent: :restrict_with_exception
  has_many :library_transfer_orders, dependent: :restrict_with_exception
  has_many :suggested_biblios

  has_one_attached :image do |attachable|
    attachable.variant :desktop_cart, resize_to_limit: [183, 260]
    attachable.variant :tab_cart, resize_to_limit: [150, 194]
    attachable.variant :mobile_cart, resize_to_limit: [156, 230]
    attachable.variant :desktop_large, resize_to_limit: [500, 620]
    attachable.variant :tab_large, resize_to_limit: [150, 194]
    attachable.variant :mobile_large, resize_to_limit: [250, 320]
  end
  has_one_attached :preview
  has_one_attached :table_of_content
  has_one_attached :full_ebook
  has_many :stock_changes, as: :stock_changeable
  has_many :library_transfer_orders, dependent: :restrict_with_exception
  has_many :book_transfer_orders, dependent: :restrict_with_exception
  has_many :lost_damaged_biblios, dependent: :restrict_with_exception
  has_many :user_suggestions, dependent: :restrict_with_exception

  accepts_nested_attributes_for :author_biblios, allow_destroy: true
  accepts_nested_attributes_for :biblio_subject_biblios, allow_destroy: true

  validates :title, presence: true
  validates_uniqueness_of :slug
  validates_uniqueness_of :isbn, if: proc { |a| a.isbn.present? }
  validates_uniqueness_of :unique_biblio, if: proc { |a| a.isbn.blank? }
  validates :image, blob: { content_type: %w[image/jpg image/jpeg image/png image/webp], size_range: 1..3.megabytes }

  scope :paper_books, -> { where(is_paper_biblio: true) }
  scope :e_books, -> { where(is_e_biblio: true) }
  scope :published, -> { where(is_published: true) }

  before_validation :set_unique_biblio, on: :create
  before_save :set_audit_user
  after_commit :update_e_book

  def image_file=(file)
    return if file.blank?

    image.attach(io: file[:tempfile],
                 filename: file[:filename],
                 content_type: file[:type])
  end

  def full_ebook_file=(file)
    return if file.blank?

    full_ebook.attach(io: file[:tempfile],
                      filename: file[:filename],
                      content_type: file[:type])
  end

  def table_of_content_file=(file)
    return if file.blank?

    table_of_content.attach(io: file[:tempfile],
                            filename: file[:filename],
                            content_type: file[:type])
  end

  def preview_file=(file)
    return if file.blank?

    preview.attach(io: file[:tempfile],
                   filename: file[:filename],
                   content_type: file[:type])
  end

  def set_unique_biblio
    unique_biblio = title.to_s.parameterize(separator: '_').present? ? title.to_s.parameterize(separator: '_') : title.to_s
    unique_biblio = "#{unique_biblio}-#{author_id}" if author_id.present?
    unique_biblio = "#{unique_biblio}-#{biblio_publication_id}" if biblio_publication_id.present?
    unique_biblio = "#{unique_biblio}-#{series_statement_volume.parameterize}" if series_statement_volume.present?
    unique_biblio = "#{unique_biblio}-#{biblio_edition_id}" if biblio_edition_id.present?
    unique_biblio = "#{unique_biblio}-#{place_of_publication.parameterize}" if place_of_publication.present?
    self.slug = unique_biblio
    self.unique_biblio = unique_biblio
  end

  def update_e_book
    return unless full_ebook_file_url.present?

    update_columns(is_e_biblio: true)

  end

  def wishlisted?(current_user)
    current_user.present? && biblio_wishlists&.find_by(user_id: current_user.id).present?
  end
  def set_audit_user
    Audited.store[:audited_user] = Staff.find_by(id: created_by_id)
    Audited.store[:audited_user] = Staff.find_by(id: updated_by_id) if persisted?
  end

  def suggest_biblio_read_count(user)
    suggest_biblio = SuggestedBiblio.find_or_create_by!(user_id: user.id, biblio_id: self.id)
    suggest_biblio.update(read_count: suggest_biblio.read_count + 1 )
  end
end
