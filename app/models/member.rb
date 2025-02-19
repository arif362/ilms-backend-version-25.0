class Member < ApplicationRecord
  audited
  # Associations
  belongs_to :user
  has_many :library_entry_logs, as: :entryable
  belongs_to :membership_request
  belongs_to :library
  belongs_to :present_division, class_name: 'Division'
  belongs_to :present_district, class_name: 'District'
  belongs_to :present_thana, class_name: 'Thana'
  belongs_to :permanent_division, class_name: 'Division'
  belongs_to :permanent_district, class_name: 'District'
  belongs_to :permanent_thana, class_name: 'Thana'
  belongs_to :created_by, polymorphic: true
  belongs_to :updated_by, polymorphic: true, optional: true
  has_many :library_cards, dependent: :restrict_with_exception
  has_many :circulations, dependent: :restrict_with_exception
  has_many :payments, dependent: :restrict_with_exception
  has_many :lost_damaged_biblios, dependent: :restrict_with_exception
  has_many :security_moneys, dependent: :restrict_with_exception
  has_many :extend_requests, dependent: :restrict_with_exception

  has_one_attached :profile_image
  has_one_attached :nid_front_image
  has_one_attached :nid_back_image
  has_one_attached :birth_certificate_image
  has_one_attached :student_id_image
  has_one_attached :verification_certificate_image

  validates :profile_image, blob: { content_type: %w[image/jpg image/jpeg image/png image/webp], size_range: 1..2.megabytes }
  validates :nid_front_image, blob: { content_type: %w[image/jpg image/jpeg image/png image/webp], size_range: 1..2.megabytes }
  validates :nid_back_image, blob: { content_type: %w[image/jpg image/jpeg image/png image/webp], size_range: 1..2.megabytes }
  validates :birth_certificate_image, blob: { content_type: %w[image/jpg image/jpeg image/png image/webp], size_range: 1..2.megabytes }
  validates :student_id_image, blob: { content_type: %w[image/jpg image/jpeg image/png image/webp], size_range: 1..2.megabytes }
  validates :verification_certificate_image, blob: { content_type: %w[image/jpg image/jpeg image/png image/webp], size_range: 1..2.megabytes }

  # Enumerators
  enum membership_category: { general: 0, student: 1, child: 2 }
  enum identity_type: { nid: 0, birth_certificate: 1, student_id: 2 }
  enum gender: { male: 0, female: 1, other: 2 }

  attr_accessor :full_name, :phone, :email, :dob

  validates_length_of :identity_number, maximum: 20

  after_create :create_library_card_request
  after_update :change_user
  before_create :age_calculator

  def self.search_unique_id_or_phone(search_term)
    joins(:user).where('users.phone like ? OR members.id like ?', "%#{search_term}%", search_term.to_i)
  end

  def unique_id
    "M-#{id.to_s.rjust(7, '0')}"
  end

  def registered_name
    user.full_name
  end

  def profile_image_file=(file)
    return if file.blank?

    profile_image.attach(io: file[:tempfile],
                         filename: file[:filename],
                         content_type: file[:type])
  end

  def nid_front_image_file=(file)
    return if file.blank?

    nid_front_image.attach(io: file[:tempfile],
                           filename: file[:filename],
                           content_type: file[:type])
  end

  def nid_back_image_file=(file)
    return if file.blank?

    nid_back_image.attach(io: file[:tempfile],
                          filename: file[:filename],
                          content_type: file[:type])
  end

  def birth_certificate_image_file=(file)
    return if file.blank?

    birth_certificate_image.attach(io: file[:tempfile],
                                          filename: file[:filename],
                                          content_type: file[:type])
  end

  def student_id_image_file=(file)
    return if file.blank?

    student_id_image.attach(io: file[:tempfile],
                 filename: file[:filename],
                 content_type: file[:type])
  end

  def verification_certificate_image_file=(file)
    return if file.blank?

    verification_certificate_image.attach(io: file[:tempfile],
                 filename: file[:filename],
                 content_type: file[:type])
  end

  def active
    is_active && expire_date > DateTime.now
  end

  private

  def change_user
    update_params = {}
    update_params[:full_name] = full_name if full_name.present? && full_name != registered_name
    update_params[:phone] = phone if phone.present? && phone != user&.phone
    update_params[:email] = email if email.present? && email != user&.email
    update_params[:gender] = gender if gender.present? && gender != user&.gender
    update_params[:dob] = dob if dob.present? && dob != user&.dob

    user.update(update_params) if update_params.present?
  end

  def age_calculator
    self.age = (Date.today.year - (user&.dob&.to_date || Date.today).year)
  end

  def create_library_card_request
    request_details = membership_request.request_detail
    library_cards.create!(
      name: full_name,
      issued_library_id: library_id,
      issue_date: Time.current,
      expire_date: Time.current.next_year(100),
      membership_category:,
      card_status_id: CardStatus.find_by(status_key: CardStatus.status_keys[:pending]).id,
      delivery_type: request_details.card_delivery_type,
      address_type: request_details.delivery_address_type,
      recipient_name: request_details.recipient_name,
      recipient_phone: request_details.recipient_phone,
      delivery_address: request_details.delivery_address,
      division_id: request_details.delivery_division_id,
      district_id: request_details.delivery_district_id,
      thana_id: request_details.delivery_thana_id
    )
  end
end
