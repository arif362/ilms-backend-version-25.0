# frozen_string_literal: true

class IntLibExtension < ApplicationRecord
  belongs_to :library_transfer_order
  belongs_to :sender_library, class_name: 'Library'
  belongs_to :receiver_library, class_name: 'Library'
  belongs_to :created_by, polymorphic: true
  belongs_to :updated_by, polymorphic: true, optional: true

  validates_presence_of :extend_end_date

  enum status: { pending: 0, accepted: 1, rejected: 2 }

  after_commit :lms_create_int_lib_extension, on: :create
  after_commit :lms_update_int_lib_extension, on: :update

  private

  def lms_create_int_lib_extension
    Lms::InterLibraryTransferManage::CreateIntLibExtensionJob.perform_later(self, created_by)
  end

  def lms_update_int_lib_extension
    return unless saved_changes.key?('status')

    Lms::InterLibraryTransferManage::UpdateIntLibExtensionJob.perform_later(self, created_by)
  end
end
