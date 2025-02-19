class BookTransferOrder < ApplicationRecord
  audited
  belongs_to :biblio
  belongs_to :library
  belongs_to :user
  has_many :notifications, as: :notificationable, dependent: :destroy
  belongs_to :updated_by, polymorphic: true, optional: true
  has_many :library_transfer_orders, as: :transferable, dependent: :restrict_with_exception

  enum status: { pending: 0, accepted: 1, rejected: 2, cancelled: 3, arrived: 4 }

  attr_accessor :sender_library_id, :start_date, :end_date

  after_save :create_int_library_transfer, if: :accepted?
  after_save :track_status_change
  after_commit :lms_create_bto, on: :create

  private

  def create_int_library_transfer
    library_transfer_order = library_transfer_orders.forword.build(user_id: user.id,
                                                                   receiver_library_id: library.id,
                                                                   sender_library_id:,
                                                                   transfer_order_status: TransferOrderStatus.get_status(:pending),
                                                                   start_date:,
                                                                   end_date:,
                                                                   updated_by:)
    library_transfer_order.add_lto_line_items(biblio_id, 1) if library_transfer_order.save!
  end

  def lms_create_bto
    Lms::InterLibraryTransferManage::CreateBookTransferOrderJob.perform_later(self, user)
  end

  def track_status_change
    # TO-DO: should move the bangla text into yaml file from here
    case status
    when 'pending'
      placed_notification
    when 'approved'
      approved_notification
    when 'rejected'
      rejected_notification
    when 'cancelled'
      cancelled_notification
    when 'arrived'
      arrived_notification
    else
      # type code here
    end
  end

  def placed_notification
    Notification.create_notification(self, user,
                                     I18n.t('Transfer Request Placed'),
                                     I18n.t('Transfer Request Placed', locale: :bn),
                                     I18n.t('Your Book Transfer Request Placed please wait for the approval'),
                                     I18n.t('Your Book Transfer Request Placed please wait for the approval', locale: :bn))
  end
  def approved_notification
    Notification.create_notification(self, user,
                                     I18n.t('Transfer Request Approved'),
                                     I18n.t('Transfer Request Approved', locale: :bn),
                                     I18n.t('Your Book Transfer Request is Approved'),
                                     I18n.t('Your Book Transfer Request is Approved', locale: :bn))
  end

  def rejected_notification
    Notification.create_notification(self, user,
                                     I18n.t('Book Transfer Request rejected'),
                                     I18n.t('Your Book Transfer Request has been rejected', locale: :bn),
                                     I18n.t('Book Transfer Request rejected'),
                                     I18n.t('Your Book Transfer Request has been rejected', locale: :bn))
  end

  def cancelled_notification
    Notification.create_notification(self, user,
                                     I18n.t('Book Transfer Request cancelled'),
                                     I18n.t('Your Book Transfer Request has been cancelled', locale: :bn),
                                     I18n.t('Book Transfer Request cancelled'),
                                     I18n.t('Your Book Transfer Request has been cancelled', locale: :bn))
  end

  def arrived_notification
    Notification.create_notification(self, user,
                                     I18n.t('Requested book arrived'),
                                     I18n.t('Your Book Transfer Request arrived to library', locale: :bn),
                                     I18n.t('Requested book arrived'),
                                     I18n.t('Your Book Transfer Request arrived to library', locale: :bn))
  end
end
