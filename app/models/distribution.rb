class Distribution < ApplicationRecord

  has_many :department_biblio_items

  enum status: { pending: 0, partially_received: 1, received: 2, in_transit: 3 }

  # after_commit on: :create do
  #   Admin::DistributionSentToLibraryJob.perform_later(self, 'created')
  # end

  after_commit on: :update do
    Admin::DistributionSentToLibraryJob.perform_later(self, 'updated')
  end

  end


