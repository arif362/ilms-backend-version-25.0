class LibraryCard < ApplicationRecord
  enum delivery_type: { home_delivery: 0, pickup: 1 }
  enum pay_type: { cash_to_library: 0, nagad_payment: 1 }
  enum address_type: { present: 0, permanent: 1, others: 2 }
  enum membership_category: { general: 0, student: 1, child: 2 }

  belongs_to :updated_by, polymorphic: true, optional: true
  belongs_to :created_by, polymorphic: true, optional: true
  belongs_to :member
  belongs_to :issued_library, class_name: 'Library'
  belongs_to :printing_library, class_name: 'Library', optional: true
  belongs_to :card_status
  belongs_to :division, optional: true
  belongs_to :district, optional: true
  belongs_to :thana, optional: true
  belongs_to :reference_card, class_name: 'LibraryCard', optional: true
  has_many :card_status_changes
  has_many :notifications, as: :notificationable, dependent: :destroy
  has_many :invoices, as: :invoiceable, dependent: :destroy

  has_one_attached :member_image
  has_one_attached :authorized_signature
  has_one_attached :damaged_card_image
  has_one_attached :gd_image

  validates :name, presence: true
  validates :smart_card_number, uniqueness: true, allow_blank: true

  scope :active, -> { where(is_active: true) }

  before_create :generate_barcode
  after_create :create_invoice_for_home_delivery
  after_save :track_status_change
  after_commit :lms_reapply_card_job

  def self.current
    active.where(expire_date: DateTime.now).last
  end

  def damaged_card_image_file=(file)
    image_file(damaged_card_image, file)
  end

  def gd_image_file=(file)
    image_file(gd_image, file)
  end

  def image_file(image_column, file)
    return if file.blank?

    image_column.attach(io: file[:tempfile],
                        filename: file[:filename],
                        content_type: file[:type])
  end

  def validate_status_update(new_status)
    case new_status
    when 'waiting_for_print' then card_status.status_key == 'pending'
    when 'accepted' then card_status.status_key == 'waiting_for_print' || card_status.status_key == 'pending'
    when 'printed' then card_status.status_key == 'accepted'
    when 'ready_for_pickup' then card_status.status_key == 'printed'
    when 'collected_by_3pl' then card_status.status_key == 'ready_for_pickup'
    when 'delivered'
      card_status.status_key == if delivery_type == 'home_delivery'
                                  'collected_by_3pl'
                                elsif issued_library_id != printing_library_id
                                  'delivered_to_library'
                                else
                                  'ready_for_pickup'
                                end
    when 'delivered_to_library' then card_status.status_key == 'collected_by_3pl' && delivery_type != 'home_delivery'
    when 'cancelled', 'rejected', 'on_hold' then true
    else false
    end
  end

  private

  def generate_barcode
    self.barcode = SecureRandom.urlsafe_base64
    generate_barcode if LibraryCard.exists?(barcode:)
  end


  def track_status_change
    return unless card_status_id_changed?

    card_status_changes.build(card_status_id: card_status.id)
    create_notification
  end

  def create_notification
    case card_status.status_key
    when 'pending'
      Notification.create_notification(self,
                                       member.user,
                                       I18n.t('Library Card Request Sent'),
                                       I18n.t('Library Card Request Sent', locale: :bn),
                                       I18n.t('Your library card request has been sent to library please wait for the approval'),
                                       I18n.t('Your library card request has been sent to library please wait for the approval', locale: :bn))
      Notification.create_notification(self,
                                       issued_library.staffs&.find_by(is_library_head: true),
                                       I18n.t('New card request'),
                                       I18n.t('New card request', locale: :bn),
                                       I18n.t('New card request to your library'),
                                       I18n.t('New card request to your library', locale: :bn))
      # notifications.create!(notifiable: issued_library.staffs&.find_by(is_library_head: true), message: 'New card request to your library', message_bn: 'BN: New card request to your library')
    when 'waiting_for_print'
      Notification.create_notification(self,
                                       issued_library.staffs&.find_by(is_library_head: true),
                                       I18n.t('New card request'),
                                       I18n.t('New card request', locale: :bn),
                                       I18n.t('New card request to your library'),
                                       I18n.t('New card request to your library', locale: :bn))
      # notifications.create!(notifiable: issued_library.staffs&.find_by(is_library_head: true), message: 'New card request to your library', message_bn: 'BN: New card request to your library')
      division_library = Library.where(thana_id: issued_library.thana.district.division.thanas.ids, library_type: 'division').first
      Notification.create_notification(self,
                                       division_library.staffs&.find_by(is_library_head: true),
                                       I18n.t('New card request'),
                                       I18n.t('New card request', locale: :bn),
                                       I18n.t('New card request to your library'),
                                       I18n.t('New card request to your library', locale: :bn))
      # notifications.create!(notifiable: division_library.staffs&.find_by(is_library_head: true), message: 'New card request to your library', message_bn: 'BN: New card request to your library') unless division_library.nil?
    when 'printed'
      Notification.create_notification(self,
                                       member.user,
                                       I18n.t('Card printed'),
                                       I18n.t('Card printed', locale: :bn),
                                       I18n.t('Card is printed'),
                                       I18n.t('Card is printed', locale: :bn))
      # notifications.create!(notifiable: member.user, message: 'Card is printed.', message_bn: 'BN: Card is printed.')
    when 'accepted'
      invoices.library_card.create(user_id: member.user_id, invoice_amount: ENV['LIBRARY_CARD_REQUEST'].to_i)
      Notification.create_notification(self,
                                       member.user,
                                       I18n.t('Request accepted'),
                                       I18n.t('Request accepted', locale: :bn),
                                       I18n.t('Your library card request has been accepted'),
                                       I18n.t('Your library card request has been accepted', locale: :bn))
      # notifications.create!(notifiable: member.user, message: 'Your library card request has been accepted', message_bn: 'BN: Your library card request has been accepted.')
    when 'rejected'
      Notification.create_notification(self,
                                       member.user,
                                       I18n.t('Request rejected'),
                                       I18n.t('Request rejected', locale: :bn),
                                       I18n.t('Your library card request has been rejected'),
                                       I18n.t('Your library card request has been rejected', locale: :bn))
      # notifications.create!(notifiable: member.user, message: 'Your library card request has been rejected', message_bn: 'BN: Your library card request has been rejected.')
    when 'ready_for_pickup'
      Notification.create_notification(self,
                                       member.user,
                                       I18n.t('Card pickup'),
                                       I18n.t('Card pickup', locale: :bn),
                                       I18n.t('Card is ready and ready for your pickup'),
                                       I18n.t('Card is ready and ready for your pickup', locale: :bn))
      # notifications.create!(notifiable: member.user, message: 'Card is ready and ready for your pickup.', message_bn: 'BN: Card is ready and ready for your pickup.')
    when 'collected_by_3pl'
      Notification.create_notification(self,
                                       member.user,
                                       I18n.t('Card delivered'),
                                       I18n.t('Card delivered', locale: :bn),
                                       I18n.t('Card is on the way for delivery'),
                                       I18n.t('Card is on the way for delivery', locale: :bn))
      # notifications.create!(notifiable: member.user, message: 'Card is on the way for delivery.', message_bn: 'BN: Card is on the way for delivery.')
    when 'cancelled'
      Notification.create_notification(self,
                                       member.user,
                                       I18n.t('Request cancelled'),
                                       I18n.t('Request cancelled', locale: :bn),
                                       I18n.t('Card request is cancelled'),
                                       I18n.t('Card request is cancelled', locale: :bn))
      # notifications.create!(notifiable: member.user, message: 'Card request is cancelled.', message_bn: 'BN: Card request cancelled.')
    when 'delivered'
      Notification.create_notification(self,
                                       member.user,
                                       I18n.t('Card delivered'),
                                       I18n.t('Card delivered', locale: :bn),
                                       I18n.t('Card is delivered'),
                                       I18n.t('Card is delivered', locale: :bn))
      # notifications.create!(notifiable: member.user, message: 'Card delivered.', message_bn: 'BN: Card delivered.')
      Notification.create_notification(self,
                                       issued_library.staff,
                                       I18n.t('Card delivered'),
                                       I18n.t('Card delivered', locale: :bn),
                                       I18n.t('Card is delivered'),
                                       I18n.t('Card is delivered', locale: :bn))
      # notifications.create!(notifiable: issued_library.staff, message: 'Card delivered.', message_bn: 'BN: Card delivered.')
    when 'delivered_to_library'
      Notification.create_notification(self,
                                       issued_library.staff,
                                       I18n.t('Card delivered'),
                                       I18n.t('Card delivered', locale: :bn),
                                       I18n.t('Card delivered to library'),
                                       I18n.t('Card delivered to library', locale: :bn))

      # notifications.create!(notifiable: issued_library.staff, message: 'Card delivered to library.', message_bn: 'BN: Card delivered to library.')
    when 'on_hold'
      Notification.create_notification(self,
                                       member.user,
                                       I18n.t('Request hold'),
                                       I18n.t('Request hold', locale: :bn),
                                       I18n.t('Card request is on hold'),
                                       I18n.t('Card request is on hold', locale: :bn))
      # notifications.create!(notifiable: member.user, message: 'Card request is on hold.', message_bn: 'BN: Card request is on hold.')
    end
  end

  def lms_reapply_card_job
    return unless is_lost.present? || is_damaged.present? || is_expired.present?

    Lms::CardManage::CardReapplyJob.perform_later(self)

  end

  def create_invoice_for_home_delivery

    return unless home_delivery?

    return if member.library_cards.count <= 1

    # Build and save the invoice
    invoices.library_card.build(invoiceable: self,
                                user_id: member.user.id,
                                invoice_amount: invoice_amount_calculation).save

  end

  def invoice_amount_calculation
    if issued_library.district.id == district&.id
      ENV['SHIPPING_CHARGE_SAME_DISTRICT']
    else
      ENV['SHIPPING_CHARGE_OTHER_DISTRICT']
    end
  end
end
