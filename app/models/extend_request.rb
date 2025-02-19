# frozen_string_literal: true

class ExtendRequest < ApplicationRecord
  belongs_to :member
  belongs_to :order, optional: true
  belongs_to :circulation
  belongs_to :library
  belongs_to :created_by, polymorphic: true
  belongs_to :updated_by, polymorphic: true

  enum status: { pending: 0, approved: 1, rejected: 2 }

  after_commit :lms_create_extend_request, on: :create

  private

  def lms_create_extend_request
    Lms::OrderManage::CreateExtendRequestJob.perform_later(self, member.user)
  end
end
