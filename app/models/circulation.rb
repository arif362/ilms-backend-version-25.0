# frozen_string_literal: true

class Circulation < ApplicationRecord
  audited
  belongs_to :library
  belongs_to :biblio_item
  belongs_to :member
  belongs_to :order, optional: true
  belongs_to :return_order, optional: true
  belongs_to :circulation_status
  has_many :circulation_status_changes
  belongs_to :created_by, polymorphic: true, optional: true
  belongs_to :updated_by, polymorphic: true, optional: true
  has_many :notifications, as: :notificationable, dependent: :destroy
  has_many :invoices, as: :invoiceable, dependent: :destroy
  has_one :lost_damaged_biblio, dependent: :restrict_with_exception
  has_one :return_item
  has_many :stock_changes, dependent: :restrict_with_exception
  has_one :return_circulation_transfer
  has_many :extend_requests, dependent: :restrict_with_exception

  validates :return_at, presence: true

  before_save :update_late_days, :add_invoice
  after_create :increment_borrow_count
  after_commit :suggest_biblio_borrow_count
  after_commit :increment_biblio_borrow_count
  after_save :create_circulation_status_change, :update_stock

  def calculate_fine
    late_days = (Date.today.end_of_day.to_date - return_at.to_date).to_i

    amount = 0
    late_days.times.each do |day|
      amount += if day <= 7
                  ENV['FIRST_WEEK_LATE_PER_DAY'].to_i
                else
                  ENV['SECOND_WEEK_LATE_PER_DAY'].to_i
                end
    end
    amount
  end

  private

  def update_late_days
    return unless circulation_status_id_changed?
    return unless circulation_status == CirculationStatus.get_status(:returned)

    self.late_days = (returned_at.to_date - return_at.to_date).to_i.positive? ? (returned_at.to_date - return_at.to_date).to_i : 0
  end

  def increment_borrow_count
    return unless circulation_status == CirculationStatus.get_status(:borrowed)

    library.update_columns(current_borrow_count: library.current_borrow_count + 1)
  end

  def increment_biblio_borrow_count
    return unless self.circulation_status == CirculationStatus.get_status(:borrowed)

      biblio = self.biblio_item.biblio
      biblio.update_columns(borrow_count: biblio.borrow_count+1) if biblio.present?

  end

  def create_circulation_status_change
    circulation_status_changes.create!(circulation_status_id:,
                                       changed_by: updated_by)

    message_key = "You have successfully requested as #{circulation_status.status_key.titleize}"
    notification = Notification.create_notification(self,
                                     member.user,
                                     I18n.t('successfully requested'),
                                     I18n.t('successfully requested', locale: :bn),
                                     I18n.t(message_key),
                                     I18n.t(message_key, locale: :bn))
    notification.save!
    # notifications.create!(notifiable: member.user, message: "You have successfully requested as #{circulation_status.status_key.titleize}",
    #                       message_bn: "BN: You have successfully requested as #{circulation_status.status_key.titleize}")
  end

  def update_stock
    return if order.present?
    return if return_order.present?
    return if extended_at.present?
    return unless CirculationStatus.status_keys.keys.include?(circulation_status)

    increase_qty = if circulation_status.borrowed?
                     'borrowed_quantity'
                   elsif circulation_status.lost?
                     'lost_quantity'
                   elsif circulation_status.damaged_returned?
                     'damaged_quantity'
                   elsif return_circulation_transfer.present? && return_circulation_transfer.return_circulation_status.pending?
                     'return_in_library_quantity'
                   else
                     'available_quantity'
                   end
    decrease_qty = get_decrease_qty
    transaction_type = circulation_status.borrowed? ? 'borrowed_at_circulation' : 'returned_at_circulation'


    ActiveRecord::Base.transaction do
      biblio_library = BiblioLibrary.find_by!(library:, biblio: biblio_item.biblio)
      if eval("biblio_library.#{decrease_qty} - 1").negative?
        Rails.logger.error "\n#{decrease_qty} is being negative for biblio_library_id: #{biblio_library.id}"
        raise "#{decrease_qty} is being negative for biblio_slug: #{biblio_library.biblio.slug}, biblio_id: #{biblio_library.biblio_id}, and library_id: #{biblio_library.library_id}"
      end
      eval("biblio_library.update!( #{decrease_qty}: biblio_library.#{decrease_qty} - 1,
                                    #{increase_qty}: biblio_library.#{increase_qty} + 1)"
          )

      if biblio_library.biblio_library_locations.blank?
        biblio_library.biblio_library_locations.first_or_create!(
          library_location: biblio_item.permanent_library_location, biblio: biblio_item.biblio)
      end
      if circulation_status.returned?
        biblio_library.biblio_library_locations&.first&.increment_quantity
      else
        biblio_library.biblio_library_locations.first.decrement_quantity
      end

      biblio_library.save_stock_change(transaction_type, 1, self,
                                       "#{decrease_qty}_change", "#{increase_qty}_change")
    end
  end

  def add_invoice
    return unless circulation_status_id_changed? && circulation_status.returned?
    return unless late_days.present? && late_days.positive?

    invoices.build(invoice_type: Invoice.invoice_types[:fine], user_id: member.user.id,
                   invoice_amount: fine_amount)
  end

  def fine_amount
    amount = 0
    late_days.times.each do |day|
      amount += if day <= 7
                  ENV['FIRST_WEEK_LATE_PER_DAY'].to_i
                else
                  ENV['SECOND_WEEK_LATE_PER_DAY'].to_i
                end
    end
    amount
  end

  def get_decrease_qty
    if circulation_status.borrowed? && order.blank?
      'available_quantity'
    elsif circulation_status.borrowed? && order&.pickup?
      order.library_id == order.pick_up_library_id ? 'on_desk_quantity' : 'in_library_quantity'
    elsif circulation_status.lost?
      'borrowed_quantity'
    elsif circulation_status.damaged_returned?
      'available_quantity'
    elsif circulation_status.borrowed? && order&.home_delivery?
      'collected_by_3pl'
    else
      'borrowed_quantity'
    end
  end

  def suggest_biblio_borrow_count
    return unless circulation_status_id == CirculationStatus.get_status('borrowed').id

    suggest_biblio = SuggestedBiblio.find_or_create_by!(user_id: self.member&.user&.id, biblio_id: self.biblio_item.biblio.id)
    suggest_biblio.update(borrow_count: suggest_biblio.borrow_count + 5)
  end
end
