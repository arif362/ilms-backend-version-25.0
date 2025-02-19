class SecurityMoney < ApplicationRecord
  audited

  belongs_to :updated_by, polymorphic: true, optional: true
  belongs_to :created_by, polymorphic: true, optional: true
  belongs_to :user
  belongs_to :member
  belongs_to :library
  belongs_to :invoice
  has_many :security_money_requests, dependent: :restrict_with_exception

  validates :amount, presence: true, numericality: { greater_than: 0 }

  enum payment_method: { cash: 0, online: 1, nagad: 2 }
  enum status: { available: 0, withdraw: 1, seized: 2 }

  def self.withdraw_able_amount(user)
    user.security_moneys.sum(:amount)
  end

end
