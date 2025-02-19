class TmpUser < ApplicationRecord
  has_many :otps, as: :otp_able, dependent: :destroy

  validates :phone, length: { is: 11 }, presence: true,
                    numericality: { only_integer: true },
                    format: { with: /(\A(\+88|0088)?(01)[3456789](\d){8})\z/, message: 'Not a valid phone number' }

  validates :email, allow_blank: true,
                    format: { with: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/, message: 'format is invalid' }


  validate :validate_user

  enum gender: { male: 0, female: 1, other: 2 }

  def validate_user
    errors.add :phone, ' has already been taken' if User.find_by(phone:)
    errors.add :email, ' has already been taken' if email.present? && User.find_by(email:)
  end
end
