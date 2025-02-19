class AccountDeletionRequest < ApplicationRecord
  belongs_to :user

  enum status: { pending: 0, accepted: 1, rejected: 2 }

  after_update :update_user_info, if: :accepted?
  after_create :account_deletion_request

  def update_member_info(staff)
    user.member&.update!(is_active: false, updated_by: staff)
  end

  private

  def update_user_info
    user.update!(is_active: false, is_deleted: true, deleted_at: DateTime.current)
  end

  def account_deletion_request
    Staff.admin.all.each do |admin_staff|
      Notification.create_notification(self, admin_staff,
                                       I18n.t('Account Deletion requests'),
                                       I18n.t('Account Deletion requests', locale: :bn),
                                       I18n.t('Submitted Account Deletion requests'),
                                       I18n.t('Submitted Account Deletion requests', locale: :bn))
    end
  end
end
