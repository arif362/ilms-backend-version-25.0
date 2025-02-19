class Staff < ApplicationRecord
  include AuthValidation
  audited
  # Associations
  belongs_to :designation
  belongs_to :role, optional: true
  belongs_to :library, optional: true
  has_one :authorization_key, as: :authable
  has_many :book_transfer_orders, as: :updated_by
  has_many :requested_biblios, as: :updated_by
  has_many :requested_biblios, as: :updated_by
  has_many :lms_logs, as: :user_able
  has_many :payments, as: :created_by
  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_limit: [250, 250]
  end
  has_one_attached :authorized_signature

  enum gender: { male: 0, female: 1, other: 2 }
  # Validations
  validates :authorized_signature, presence: true, if: :is_library_head?
  validates :name, presence: true, length: { in: 2..32 }
  validates :email, uniqueness: true,
                    format: { with: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/, message: 'format is invalid' },
                    on: :create
  validates_presence_of :staff_type
  validates_presence_of :library_id, if: :library?
  validates_presence_of :role_id, if: :admin?
  validates :staff_type, inclusion: { in: %w[admin library],
                                      message: '%<value>s is not a valid staff_type' }, on: :create
  validates :avatar, blob: { content_type: %w[image/jpg image/jpeg image/png image/webp], size_range: 1..3.megabytes }
  has_many :notifications, as: :notifiable

  # Enum
  enum staff_type: { admin: 0, library: 1 }

  # Default Scope
  default_scope { where(is_deleted: false) }

  # Scopes
  scope :active, -> { where(is_active: true, is_deleted: false) }
  scope :except_system_admin, -> { where(is_ils_system_admin: false, is_lms_system_admin: false) }

  # callbacks
  before_commit :check_library_head
  after_commit on: :update do
    Admin::StaffDeactivateJob.perform_later(self) if library? && is_active == false
  end

  after_commit :push_to_lms, on: :update

  def unique_id
    "S-#{id.to_s.rjust(5, '0')}"
  end

  def self.library_head
    find_by(is_library_head: true)
  end

  def avatar_image=(file)
    return if file.blank?

    avatar.attach(io: file[:tempfile],
                  filename: file[:filename],
                  content_type: file[:type])
  end

  def authorized_signature_image=(file)
    return if file.blank?

    authorized_signature.attach(io: file[:tempfile],
                                filename: file[:filename],
                                content_type: file[:type])
  end

  def send_reset_password_token
    PasswordMailer.forgot_password(generate_reset_password_token, self).deliver_later
  end

  private

  def generate_reset_password_token
    signed_id(purpose: 'reset password', expires_in: (ENV['RESET_PASSWORD_TOKEN_EXPIRY'] || 15).to_i.minutes)
  end

  def check_library_head
    return unless is_library_head?

    if staff_type == 'library'
      errors.add(:base, 'Library head already exists') unless library.staffs.where(is_library_head: true).blank?
      errors.add(:base, 'Authorized signature must exist') unless authorized_signature.present?
    else
      errors.add(:base, 'Invalid staff type for head of library staff')
    end
  end

  def check_library_head_on_update
    return unless is_library_head? && library_id_changed? && staff_type == 'library'

    errors.add(:base, 'Library head already exists') unless library.staffs.where(is_library_head: true).blank?
  end

  def push_to_lms
    Lms::StaffUpdateLmsPushJob.perform_later(self)
  end
end
