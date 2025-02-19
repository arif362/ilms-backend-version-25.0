require 'uri'
require 'net/http'
class Library < ApplicationRecord
  include UsernameAuthValidation
  audited

  belongs_to :thana
  belongs_to :district, optional: true
  has_many :members, dependent: :restrict_with_exception
  has_many :authorization_keys, as: :authable, dependent: :destroy
  has_many :complains, dependent: :restrict_with_exception
  has_many :orders
  has_many :event_libraries
  has_many :events, through: :event_libraries
  has_many :library_cards, foreign_key: :issued_library_id
  has_many :printing_library_cards, class_name: 'Library', foreign_key: :printing_library_id
  has_many :event_registrations
  has_many :users, through: :event_registrations
  has_many :staffs, dependent: :restrict_with_exception
  has_many :library_locations, dependent: :restrict_with_exception
  has_many :biblio_libraries, dependent: :restrict_with_exception
  has_many :stock_changes, as: :stock_changeable
  has_many :circulations, dependent: :restrict_with_exception
  has_many :circulation_status_changes, through: :circulations
  has_many :book_transfer_orders, dependent: :restrict_with_exception
  has_many :sender_library_transfer_orders, class_name: 'LibraryTransferOrder', foreign_key: :sender_library_id
  has_many :receiver_library_transfer_orders, class_name: 'LibraryTransferOrder', foreign_key: :receiver_library_id
  has_many :user_qr_codes, dependent: :restrict_with_exception
  has_many :lost_damaged_biblios, dependent: :restrict_with_exception
  has_many :biblio_items, dependent: :restrict_with_exception
  has_many :albums, dependent: :restrict_with_exception
  has_many :library_working_days, dependent: :restrict_with_exception
  has_many :physical_reviews, dependent: :restrict_with_exception
  has_many :library_newspapers, dependent: :restrict_with_exception
  has_many :security_moneys, dependent: :restrict_with_exception
  has_many :rebind_biblios, dependent: :restrict_with_exception
  has_many :return_orders, dependent: :restrict_with_exception
  has_many :return_circulation_transfers, dependent: :restrict_with_exception
  has_many :requested_biblios, dependent: :restrict_with_exception
  has_many :security_money_requests, dependent: :restrict_with_exception
  has_many :lms_logs, as: :user_able
  has_many :extend_requests, dependent: :restrict_with_exception
  has_many :lms_reports
  has_many :department_biblio_items, dependent: :restrict_with_exception
  has_one_attached :hero_image do |image|
    image.variant :thumb, resize_to_limit: [610, 400]
  end
  has_many_attached :images do |image|
    image.variant :small, resize_to_limit: [295, 190]
    image.variant :large, resize_to_limit: [610, 400]
  end

  validates :name, :bn_name, :redx_area_id, presence: true, uniqueness: true, allow_blank: false
  validates :phone, uniqueness: true, allow_blank: false, if: -> { phone.present? }
  validates :ip_address, presence: true, uniqueness: true, on: :create, allow_blank: false
  validates_presence_of :library_type
  validates_uniqueness_of :name, :bn_name, scope: :thana_id
  validates_uniqueness_of :code, on: :create
  validates_length_of :name, :bn_name, minimum: 3
  validates_length_of :description, :bn_description, minimum: 10
  validates :images, blob: { content_type: %w[image/jpg image/jpeg image/png image/webp], size_range: 1..3.megabytes }
  accepts_nested_attributes_for :library_working_days, allow_destroy: true

  before_create :set_code
  before_create :set_district
  after_update :destroy_library_working_hours
  after_commit :create_redx_pick_up_store, on: :create
  enum library_type: { division: 0, district: 1, special: 2, upazila: 3, branch: 4, central: 5}

  scope :active, -> { where(is_active: true) }

  def biblio_available?(biblio_id)
    biblio_libraries.find_or_create_by!(biblio_id: biblio_id).available_quantity.positive?
  end

  def hero_image_file=(file)
    return if file.blank?

    hero_image.attach(io: file[:tempfile],
                      filename: file[:filename],
                      content_type: file[:type])
  end

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

  def set_code
    self.code = "L-#{(Library&.last&.id.to_i + 1).to_s.rjust(3, '0')}"
  end

  def set_district
    self.district_id = thana&.district&.id
  end
  def unique_requested_biblio(params)
    requested_biblios = self.requested_biblios.where(biblio_title: params[:biblio_title],
                                                     authors_name: params[:authors_name],
                                                     biblio_subjects_name: params[:biblio_subjects_name],
                                                     isbn: params[:isbn],
                                                     publication: params[:publication],
                                                     edition: params[:edition],
                                                     volume: params[:volume])
    return if requested_biblios.blank?

    if params[:author_requested_biblios_attributes].present?
      requested_biblios = check_authors(requested_biblios, params[:author_requested_biblios_attributes])
    end
    return unless params[:biblio_subject_requested_biblios_attributes].present? && requested_biblios.present?

    check_subjects(requested_biblios, params[:biblio_subject_requested_biblios_attributes])
  end

  def check_authors(requested_biblios, author_ids)
    requested_biblios.joins(:authors).where(authors: {id: author_ids.map { |hash| hash["author_id"] }})
  end

  def check_subjects(requested_biblios, subject_ids)
    requested_biblios.joins(:biblio_subjects).where(biblio_subjects: { id: subject_ids.map { |hash| hash["biblio_subject_id"] } })
  end

  def working_url?(url)
    uri = URI.parse(url)
    uri.is_a?(URI::HTTP) && !uri.host.nil? && %w[4001 4002 8000].include?(ip_address.split(':').last)
  rescue URI::InvalidURIError
    false
  end

  private

  def destroy_library_working_hours
    return unless is_default_working_days?

    library_working_days&.destroy_all
  end

  def create_redx_pick_up_store
    ThreePs::CreatePickUpStoreJob.perform_later(self)
  end
end
