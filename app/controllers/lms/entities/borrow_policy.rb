# frozen_string_literal: true

module Lms
  module Entities
    class BorrowPolicy < Grape::Entity

      expose :id
      expose :item_type, using: Lms::Entities::ItemTypes
      expose :category
      expose :note
      expose :checkout_allowed
      expose :fine_changing_interval
      expose :overdue
      expose :is_renewal_allowed
      expose :renewal_period
      expose :renewal_times
      expose :is_automatic_renewal
      expose :max_renewal_day
      expose :hold_allowed_daily
      expose :hold_allowed_total
      expose :fine_discount
      expose :status
      expose :not_loanable
    end
  end
end
