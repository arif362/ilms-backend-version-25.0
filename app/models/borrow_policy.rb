# frozen_string_literal: true

class BorrowPolicy < ApplicationRecord
  belongs_to :item_type
  validates_uniqueness_of :item_type_id, scope: :category

  scope :not_deleted, -> { where(is_deleted: false) }

  enum category: { staff: 0, child: 1, student: 2, general: 3 }
  enum status: { inactive: 0, active: 1 }
  enum not_loanable: { no: 0, yes: 1 }
end
