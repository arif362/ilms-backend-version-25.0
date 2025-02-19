class ThirdPartyUser < ApplicationRecord
  include AuthValidation
  scope :active, -> { where(is_active: true) }
  has_one :authorization_key, as: :authable, dependent: :destroy
  has_many :lms_logs, as: :user_able
  has_many :orders, as: :updated_by

  validates :email, presence: true, uniqueness: true,
                    format: { with: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/, message: 'format is invalid' }


  enum service_type: { customer_care_support: 0, delivery_support: 1, chat_bot_support: 2, sms: 3 }

end
