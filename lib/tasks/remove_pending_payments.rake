# frozen_string_literal: true
namespace :remove_pending_payments do
  desc 'Remove payments created 1 hour ago with pending status'
  task remove_expired_payments: :environment do
    one_hour_ago = 1.hour.ago

    # Find and destroy payments meeting the criteria
    Payment.pending
           .where('created_at <= ?', one_hour_ago)
           .destroy_all
    puts 'Removed expired pending payments created 1 hour ago.'
  end
end
