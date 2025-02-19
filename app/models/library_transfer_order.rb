# frozen_string_literal: true

class LibraryTransferOrder < ApplicationRecord
  audited
  belongs_to :user, optional: true
  belongs_to :transferable, polymorphic: true, optional: true
  belongs_to :transfer_order_status
  belongs_to :biblio
  belongs_to :sender_library, class_name: 'Library', optional: true
  belongs_to :receiver_library, class_name: 'Library'
  belongs_to :updated_by, polymorphic: true, optional: true
  has_many :transfer_order_status_changes, dependent: :destroy
  has_many :lto_line_items, dependent: :destroy
  has_many :int_lib_extensions, dependent: :restrict_with_exception

  enum order_type: { forword: 0, return: 1 }

  after_save :create_transfer_order_status_change
  after_save :update_arrival
  after_commit :create_lms_lto, on: :create

  def add_lto_line_items(biblio_id, quantity)
    lto_line_items.create!(biblio_id:, quantity:)
  end

  def line_items_filled_up?
    lto_line_items.where(biblio_item_id: nil).count.zero?
  end

  def add_as_other_library_biblio
    lto_line_items.each do |line_item|
      OtherLibraryBiblio.add_other_library_biblio(self, receiver_library_id, sender_library_id, line_item.biblio_item)
    end
  end

  private

  def create_transfer_order_status_change
    transfer_order_status_changes.find_or_create_by!(transfer_order_status_id:,
                                                     changed_by: updated_by)
  end

  def update_arrival
    return unless transfer_order_status.delivered?
    return unless forword?

    transferable.update_columns(arrived_at: Time.current, status: :arrived)
  end

  def create_lms_lto
    if forword?
      Lms::InterLibraryTransferManage::CreateLibraryTransferOrderJob.perform_later(self, updated_by)
    else
      Lms::InterLibraryTransferManage::CreateLtoReturnJob.perform_later(self, updated_by)
    end
  end
end
