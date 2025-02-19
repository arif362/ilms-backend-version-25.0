class PhoneChangeRequest < ApplicationRecord
  belongs_to :user
  has_many :otps, as: :otp_able, dependent: :destroy

  validates_presence_of :phone
end
