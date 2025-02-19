class RequestDetail < ApplicationRecord
  enum membership_category: { general: 0, student: 1, child: 2 }
  enum identity_type: { nid: 0, birth_certificate: 1, student_id: 2 }
  enum gender: { male: 0, female: 1, other: 2 }
  enum card_delivery_type: { pickup: 0, home_delivery: 1 }
  enum delivery_address_type: { present: 0, permanent: 1, others: 2 }

  belongs_to :updated_by, polymorphic: true, optional: true
  belongs_to :created_by, polymorphic: true, optional: true
  belongs_to :library
  belongs_to :present_division, class_name: 'Division'
  belongs_to :present_district, class_name: 'District'
  belongs_to :present_thana, class_name: 'Thana'
  belongs_to :permanent_division, class_name: 'Division'
  belongs_to :permanent_district, class_name: 'District'
  belongs_to :permanent_thana, class_name: 'Thana'
  belongs_to :delivery_division, class_name: 'Division', optional: true
  belongs_to :delivery_district, class_name: 'District', optional: true
  belongs_to :delivery_thana, class_name: 'Thana', optional: true
  has_one :membership_request, dependent: :restrict_with_exception
  has_many :lms_logs, as: :user_able


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

  # after_create :set_delivery_info

  attr_accessor :save_address, :address_name, :present_delivery_area_id, :present_delivery_area, :permanent_delivery_area, :permanent_delivery_area_id

  after_create :save_new_address, :update_basic_info

  validates :identity_number, length: { maximum: 20 }
  validate :custom_identity_number_uniqueness

  def profile_image_file=(file)
    image_file(profile_image, file)
  end

  def nid_front_image_file=(file)
    image_file(nid_front_image, file)
  end

  def nid_back_image_file=(file)
    image_file(nid_back_image, file)
  end

  def birth_certificate_image_file=(file)
    image_file(birth_certificate_image, file)
  end

  def student_id_image_file=(file)
    image_file(student_id_image, file)
  end

  def verification_certificate_image_file=(file)
    image_file(verification_certificate_image, file)
  end

  def image_file(image_column, file)
    return if file.blank?

    image_column.attach(io: file[:tempfile],
                        filename: file[:filename],
                        content_type: file[:type])
  end

  def set_delivery_info
    return if others?

    self.delivery_division_id = present? ? present_division_id : permanent_division_id
    self.delivery_district_id = present? ? present_district_id : permanent_district_id
    self.delivery_thana_id = present? ? present_thana_id : permanent_thana_id
    self.delivery_address = present? ? present_address : permanent_address
    save!
  end

  private

  def save_new_address
    return unless save_address.present?

    SavedAddress.add_address(membership_request.user, address_name, delivery_address, delivery_division_id, delivery_district_id, delivery_thana_id, recipient_name, recipient_phone, present_delivery_area_id, present_delivery_area_id)
  end

  def update_basic_info
    membership_request.user.update!(full_name:, email:)
  end

  def custom_identity_number_uniqueness
    return true unless RequestDetail.where(identity_number:, identity_type:).present?

    existing_user_ids = Member.where(identity_number:, is_active: true).pluck(:user_id).uniq
    if existing_user_ids.present? && existing_user_ids.count >= 1 && existing_user_ids[0] != membership_request.user.id
      raise "#{identity_type.upcase.to_s} has already been taken"

    end
    true
  end
end
