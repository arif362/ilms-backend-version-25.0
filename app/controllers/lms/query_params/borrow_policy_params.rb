# frozen_string_literal: true

module Lms
  module QueryParams
    module BorrowPolicyParams
      extend ::Grape::API::Helpers

      params :borrow_policy_create_params do
        requires :staff_id, type: Integer
        requires :item_type_id, type: Integer
        requires :category, type: String, values: BorrowPolicy.categories
        requires :note, type: String
        requires :checkout_allowed, type: Integer
        requires :fine_changing_interval, type: Integer
        requires :overdue, type: Integer
        requires :is_renewal_allowed, type: Boolean
        requires :renewal_period, type: Integer
        requires :renewal_times, type: Integer
        requires :is_automatic_renewal, type: Boolean
        requires :max_renewal_day, type: Integer
        requires :hold_allowed_daily, type: Integer
        requires :hold_allowed_total, type: Integer
        requires :fine_discount, type: Integer
        requires :status, type: String, values: BorrowPolicy.statuses
        requires :not_loanable, type: String, values: BorrowPolicy.not_loanables
      end

      params :borrow_policy_update_params do
        requires :staff_id, type: Integer
        requires :item_type_id, type: Integer
        requires :category, type: String, values: BorrowPolicy.categories
        requires :note, type: String
        requires :checkout_allowed, type: Integer
        requires :fine_changing_interval, type: Integer
        requires :overdue, type: Integer
        requires :is_renewal_allowed, type: Boolean
        requires :renewal_period, type: Integer
        requires :renewal_times, type: Integer
        requires :is_automatic_renewal, type: Boolean
        requires :max_renewal_day, type: Integer
        requires :hold_allowed_daily, type: Integer
        requires :hold_allowed_total, type: Integer
        requires :fine_discount, type: Integer
        requires :status, type: String, values: BorrowPolicy.statuses
        requires :not_loanable, type: String, values: BorrowPolicy.not_loanables
      end

      params :borrow_policy_delete_params do
        requires :staff_id, type: Integer
      end
    end
  end
end
