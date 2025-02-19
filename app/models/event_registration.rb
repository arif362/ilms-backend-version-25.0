# frozen_string_literal: true

class EventRegistration < ApplicationRecord
  audited
  belongs_to :library
  belongs_to :user
  belongs_to :event
  has_many :notifications, as: :notificationable, dependent: :destroy

  enum identity_type: { not_applicable: 0, birth_certificate: 1, nid: 2 }
  enum participate_group: { a: 0, b: 1, c: 2, d: 3, e: 4 }
  enum status: { pending: 0, approved: 1, rejected: 2, cancel: 3 }

  # validates :competition_name, presence: true
  validates :phone, allow_blank: true,
                    format: { with: /(\A(\+88|0088)?(01)[3456789](\d){8})\z/,
                              message: 'Not a valid phone number' }
  before_save :set_audit_user
  after_create :increment_registered_user
  after_update :decrement_registered_user, if: :cancel?
  after_commit on: :create do
    Lms::EventRegistrationJob.perform_later(self, 'created')
  end
  after_commit :registration_notification
  #
  # after_commit on: :update do
  #   Lms::EventRegistrationJob.perform_later(self, 'updated') if status == 'cancel'
  # end

  private



  def registration_notification
    case self.status
    when 'pending'
      notification = Notification.create_notification(self,
                                                       self.user,
                                                       I18n.t('Your Event Registration Request Submitted'),
                                                       I18n.t('Your Event Registration Request Submitted', locale: :bn),
                                                       I18n.t('Your have successfully Submitted membership, your request need approval'),
                                                       I18n.t('Your have successfully Submitted membership, your request need approval', locale: :bn))
      notification.save
    when 'approved'

      notification  = Notification.create_notification(self,
                                                        self.user,
                                                        I18n.t('Your Event Registration Approved'),
                                                        I18n.t('Your Event Registration Approved', locale: :bn),
                                                        I18n.t('Your event registration request has been Approved'),
                                                        I18n.t('Your event registration request has been Approved', locale: :bn))
      notification.save

    when 'rejected'

      notification = Notification.create_notification(self,
                                                       self.user,
                                                       I18n.t('Your Event Registration Request Rejected'),
                                                       I18n.t('Your Event Registration Request Rejected', locale: :bn),
                                                       I18n.t('Your event registration Request Has Been Rejected'),
                                                       I18n.t('Your event registration Request Has Been Rejected', locale: :bn))
      notification.save

    when 'cancel'

      notification = Notification.create_notification(self,
                                                       self.user,
                                                       I18n.t('Your Event Registration Request canceled'),
                                                       I18n.t('Your Event Registration Request canceled', locale: :bn),
                                                       I18n.t('Your Event Registration Successfully canceled'),
                                                       I18n.t('Your Event Registration Successfully canceled', locale: :bn))
      notification.save
    end

  end

  def increment_registered_user
    event_library = EventLibrary.find_or_create_by!(library_id:, event_id:)
    event_library.update!(total_registered: event_library.total_registered + 1)
    event = self.event
    event.update_columns(total_registered: event.total_registered + 1)
  end

  def decrement_registered_user
    event_library = EventLibrary.find_or_create_by!(library_id:, event_id:)
    event_library.update!(total_registered: event_library.total_registered - 1)
    event = self.event
    event.update_columns(total_registered: event.total_registered - 1)
  end

  def set_audit_user
    Audited.store[:audited_user] = Staff.find_by(id: created_by_id)
    Audited.store[:audited_user] = Staff.find_by(id: updated_by_id) if persisted?
  end
end
