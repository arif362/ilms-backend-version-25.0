class Guest < ApplicationRecord
  belongs_to :library
  has_many :library_entry_logs, as: :entryable

  enum gender: { male: 0, female: 1, other: 2 }

  validates :name, :phone, :email, :gender, :dob, presence: true
  validates :token, uniqueness: true

  before_create :generate_token

  def unique_id
    "T-#{id.to_s.rjust(10, '0')}"
  end

  def registered_name
    name
  end

  protected

  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64(8)
      break random_token unless Guest.exists?(token: random_token)
    end
  end
end
