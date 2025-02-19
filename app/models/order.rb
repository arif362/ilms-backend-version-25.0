class Order < ApplicationRecord
  include Lms::Helpers::DeliveryChargeHelper
  enum delivery_type: { home_delivery: 0, pickup: 1 }
  enum address_type: { present: 0, permanent: 1, others: 2 }
  enum pay_type: { cash_to_library: 0, nagad: 1 }
  enum pay_status: {
    pending: 0,
    paid: 1,
    failed: 2
  }

  attr_accessor :save_address, :address_name

  belongs_to :user
  belongs_to :library
  belongs_to :pick_up_library, class_name: 'Library', optional: true
  belongs_to :division, optional: true
  belongs_to :district, optional: true
  belongs_to :thana, optional: true
  belongs_to :order_status
  belongs_to :updated_by, polymorphic: true, optional: true
  has_many :line_items, dependent: :destroy
  has_many :order_status_changes, dependent: :destroy
  has_many :notifications, as: :notificationable, dependent: :destroy
  has_many :stock_changes, as: :stock_changeable
  has_many :invoices, as: :invoiceable
  has_many :circulations, dependent: :restrict_with_exception

  before_save :track_status_change
  after_create :create_status_change
  after_save :update_stock, :add_to_circulation
  after_commit :push_to_lms

  scope :with_status, ->(statuses) { joins(:order_status).where('order_statuses.status_key': statuses) }
  scope :finished, -> { with_status(OrderStatus::FINISHED_STATUSES) }

  def unique_id
    "O#{delivery_type[0].upcase}R-#{id.to_s.rjust(8, '0')}"
  end

  def self.with_status(status_key)
    joins(:order_status).where('order_statuses.status_key = ?', OrderStatus.status_keys[status_key])
  end

  def line_items_filled_up?
    line_items.where(biblio_item_id: nil).count.zero?
  end

  def reset_total_amount
    self.total = line_items.where.not(biblio_item_id: nil).sum(:price)
  end

  private

  def track_status_change
    return unless order_status_id_changed?

    trigger_event
    order_status_changes.build(order_status_id: order_status.id, changed_by: updated_by)
  end

  def create_status_change
    order_status_changes.build(order_status_id: order_status.id, changed_by: updated_by)
  end

  def update_stock
    return unless stock_info[:will_stock_update]

    ActiveRecord::Base.transaction do
      line_items.each do |line_item|
        biblio_library = BiblioLibrary.find_by!(library:, biblio: line_item.biblio)
        if eval("biblio_library.#{stock_info[:decrease]} - line_item.quantity").negative?
          Rails.logger.error "\n#{stock_info[:decrease]} is being negative for biblio_library_id: #{biblio_library.id}"
          # raise "#{stock_info[:decrease]} is being negative for biblio_slug: #{biblio_library.biblio.slug}, biblio_id: #{biblio_library.biblio_id}, and library_id: #{biblio_library.library_id}"
        end
        eval("biblio_library.update!(
          #{stock_info[:decrease]}: biblio_library.#{stock_info[:decrease]} - line_item.quantity,
          #{stock_info[:increase]}: biblio_library.#{stock_info[:increase]} + line_item.quantity,
        )")

        if stock_info[:change_location_stock] && biblio_library.biblio_library_locations.present?
          if stock_info[:change_location_stock_type] == 'increase'
            biblio_library.biblio_library_locations.first.increment_quantity
          elsif stock_info[:change_location_stock_type] == 'decrease'
            biblio_library.biblio_library_locations.first.decrement_quantity
          end
        end

        biblio_library.save_stock_change(stock_info[:transaction_type], line_item.quantity, self,
                                         stock_info[:decrease].concat('_change'), stock_info[:increase].concat('_change'))
      end
    end
  end
  def add_to_circulation
    return unless OrderStatus.get_status(OrderStatus.status_keys[:delivered]) == order_status

    line_items.each do |li|
      circulations.create!(library_id:, member_id: user.member.id,
                           biblio_item_id: li.biblio_item_id,
                           circulation_status: CirculationStatus.get_status(:borrowed),
                           return_at: DateTime.now + ENV['BORROW_DAYS'].to_i)
    end

  end

  def trigger_event
    case order_status.status_key
    when 'order_placed'
      place_events
    when 'order_confirmed'
      confirm_events
    when 'ready_for_pickup'
      pickup_events
    when 'collected_by_3pl'
      three_pl_events
    when 'delivered'
      delivery_events
    when 'cancelled'
      cancelled_events
    when 'rejected'
      rejected_events
    end
  end
  def stock_info
    case order_status.status_key
    when 'order_placed'
      place_info
    when 'order_confirmed'
      confirm_info
    when 'ready_for_pickup'
      pickup_info
    when 'collected_by_3pl'
      three_pl_info
    when 'delivered_to_library'
      delivery_in_pick_up_lib_info
    when 'delivered'
      delivery_info
    when 'cancelled'
      cancelled_info
    when 'rejected'
      rejected_info
    end
  end

  def invoice_amount
    shipping_charge + shipping_charge_vat
  end

  def shipping_charge
    biblio_ids = line_items.map(&:biblio_id)

    calculate_delivery_charge(library, biblio_ids)
  end

  def place_events
    title_key = 'Order placed'
    message_key = 'Order placed Please wait for the library confirmation'
    Notification.create_notification(self,
                                     user,
                                     I18n.t(title_key),
                                     I18n.t(title_key, locale: :bn),
                                     I18n.t(message_key),
                                     I18n.t(message_key, locale: :bn))
  end

  def confirm_events

    if pickup?
      self.pay_status = 'paid'
      return
    end
    self.total = invoice_amount
    invoices.create!(user_id:, invoice_amount:, shipping_charge_vat:, shipping_charge:,
                     invoice_type: Invoice.invoice_types[:third_party])
    title_key = 'Order Confirmed'
    message_key = 'Please make your payment'
    Notification.create_notification(self,
                                     user,
                                     I18n.t(title_key),
                                     I18n.t(title_key, locale: :bn),
                                     I18n.t(message_key),
                                     I18n.t(message_key, locale: :bn))
    Sms::SendOtp.call(phone: user.phone,
                      message: "(DPL) Your Book borrow request (#{unique_id}) has been confirmed by the (#{library.name}). Please complete your payment for further process.")
  end

  def pickup_events
    if pickup?
      title_key = 'Ready to pickup'
      message_key = 'Your order is ready for pickup'
      Notification.create_notification(self,
                                       user,
                                       I18n.t(title_key),
                                       I18n.t(title_key, locale: :bn),
                                       I18n.t(message_key),
                                       I18n.t(message_key, locale: :bn))
    else
      # TODO: notify 3pl for pickup for home delivery
      ThreePs::CreateParcelJob.perform_later(self)
    end
  end

  def three_pl_events
    Notification.create_notification(self,
                                     user,
                                     I18n.t('Order collected'),
                                     I18n.t('Order collected', locale: :bn),
                                     I18n.t('Order was collected by delivery company'),
                                     I18n.t('Order was collected by delivery company', locale: :bn))
  end

  def delivery_events
    Notification.create_notification(self,
                                     user,
                                     I18n.t('Order delivered'),
                                     I18n.t('Order delivered', locale: :bn),
                                     I18n.t('Order was delivered to the delivery company'),
                                     I18n.t('Order was delivered to the delivery company', locale: :bn))
  end

  def cancelled_events
    Notification.create_notification(self,
                                     user,
                                     I18n.t('Order cancelled'),
                                     I18n.t('Order cancelled', locale: :bn),
                                     I18n.t('Order cancelled'),
                                     I18n.t('Order cancelled', locale: :bn))
  end

  def rejected_events
    Notification.create_notification(self,
                                     user,
                                     I18n.t('Order rejected'),
                                     I18n.t('Order rejected', locale: :bn),
                                     I18n.t('Order rejected'),
                                     I18n.t('Order rejected', locale: :bn))
  end

  def place_info
    {
      will_stock_update: true,
      transaction_type: 'order_placed',
      decrease: 'available_quantity',
      increase: 'booked_quantity',
      change_location_stock_type: nil,
      change_location_stock: false
    }
  end

  def confirm_info
    {
      will_stock_update: false,
      transaction_type: 'order_confirm',
      change_location_stock_type: nil,
      change_location_stock: false
    }
  end

  def pickup_info
    {
      will_stock_update: true,
      transaction_type: 'order_pack',
      decrease: 'booked_quantity',
      increase: 'on_desk_quantity',
      change_location_stock_type: 'decrease',
      change_location_stock: true
    }
  end

  def three_pl_info
    {
      will_stock_update: true,
      transaction_type: 'order_in_3pl',
      decrease: 'on_desk_quantity',
      increase: 'three_pl_quantity',
      change_location_stock_type: nil,
      change_location_stock: false
    }
  end

  def delivery_info
    {
      will_stock_update: false,
      transaction_type: 'order_delivered',
      change_location_stock_type: nil,
      change_location_stock: false
    }
  end

  def delivery_in_pick_up_lib_info
    {
      will_stock_update: true,
      transaction_type: 'three_pl_delivered_to_library',
      decrease: 'three_pl_quantity',
      increase: 'in_library_quantity',
      change_location_stock_type: nil,
      change_location_stock: false
    }
  end

  def cancelled_info
    {
      will_stock_update: true,
      transaction_type: 'cancel_from_order_placed',
      decrease: 'booked_quantity',
      increase: 'available_quantity',
      change_location_stock_type: 'increase',
      change_location_stock: true
    }
  end

  def rejected_info
    {
      will_stock_update: true,
      transaction_type: 'reject_from_order_placed',
      decrease: 'booked_quantity',
      increase: 'available_quantity',
      change_location_stock_type: 'increase',
      change_location_stock: true
    }
  end

  def push_to_lms
    if order_status.order_placed?
      Lms::OrderManage::CreateOrderJob.perform_later(self, user)
    elsif pickup?
      Lms::OrderManage::UpdateOrderJob.perform_later(self, updated_by) if library_id != pick_up_library_id
    end

    if home_delivery? && order_status.ready_for_pickup? && paid?
      Lms::UpdatePayStatusOrderJob.perform_later(self)
    elsif home_delivery? && paid? && order_status.delivered? || order_status.collected_by_3pl?
      Lms::OrderManage::UpdateOrderJob.perform_later(self, updated_by)
    elsif order_status.cancelled?
      Lms::OrderManage::UpdateOrderJob.perform_later(self, updated_by)
      ThreePs::UpdateParcelJob.perform_later(self) if home_delivery?
    end

  end

  def shipping_charge_vat
    home_delivery? ? (shipping_charge * ENV['SHIPPING_CHARGE_VAT'].to_f).round : 0
  end
end
