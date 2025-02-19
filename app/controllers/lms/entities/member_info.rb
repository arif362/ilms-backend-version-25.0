module Lms
  module Entities
    class MemberInfo < Grape::Entity
      include Lms::Helpers::ImageHelpers

      expose :id
      expose :full_name
      expose :email
      expose :phone
      expose :dob
      expose :gender
      expose :image, as: :profile_image_url, format_with: :image_path
      expose :addresses
      expose :member
      expose :circulation_history
      expose :security_money_history
      expose :security_money_withdraw_history
      expose :fine_history
      expose :fine_due
      expose :return_history
      expose :library_card
      expose :available_loan_count

      def addresses
        object.saved_addresses
        PublicLibrary::Entities::SavedAddresses.represent(object.saved_addresses)
      end

      def member
        object&.member
      end

      def library_card
        member&.library_cards&.last
      end

      def fine_due
        object.invoices.pending.fine.sum(:invoice_amount)
      end

      def available_loan_count
        if member.present?
          loanable_qty = ENV['MAX_BORROW'].to_i - (member.user.items_on_hand + member.user&.cart&.cart_items&.count.to_i)
          loanable_qty.positive? ? loanable_qty : 0
        else
          0
        end
      end

      def circulation_history
        Lms::Entities::Circulations.represent(member&.circulations)
      end

      def security_money_history
        object.security_moneys
      end

      def security_money_withdraw_history
        object.security_money_requests
      end

      def fine_history
        object.payments.fine
      end

      def return_history
        object.return_orders
      end

    end
  end
end
