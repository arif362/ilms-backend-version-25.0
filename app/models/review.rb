class Review < ApplicationRecord
  belongs_to :biblio
  belongs_to :user
  has_many :notifications, as: :notificationable, dependent: :destroy
  validates :rating, numericality: { in: 1..5 }
  enum status: { pending: 0, approved: 1, rejected: 2 }

  scope :approved, -> { where(status: :approved) }

  after_update :track_status_change
  after_create :review_notification


  private

  def track_status_change
    change_biblio_avg_rating if saved_change_to_status?
  end

  def change_biblio_avg_rating
    review_count = biblio.reviews.approved.count
    biblio.update_columns(average_rating: biblio_average_rating(review_count), total_reviews: review_count)
  end

  def biblio_average_rating(review_count)
    return 0 if review_count.zero?

    biblio.reviews.approved.sum(:rating).to_f / review_count
  end

  def review_notification
    Staff.admin.all.each do |admin_staff|
      notification = Notification.create_notification(self, admin_staff,
                                                      I18n.t('Book Review'),
                                                      I18n.t('Book Review', locale: :bn),
                                                      I18n.t('Submitted Book Review'),
                                                      I18n.t('Submitted Book Review', locale: :bn))
      notification.save
    end
  end
end
