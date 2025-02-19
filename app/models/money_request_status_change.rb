class MoneyRequestStatusChange < ApplicationRecord
  belongs_to :security_money_request

  enum status: { pending: 0, approved: 1, rejected: 2, available_to_withdraw: 3, withdrawn: 4 }

end
