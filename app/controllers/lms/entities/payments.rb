# frozen_string_literal: true

module Lms
  module Entities
    class Payments < Grape::Entity
      expose :id
      expose :payment_type, as: :payment_method
      expose :status
      expose :amount
      expose :trx_id
      expose :purpose
      expose :created_at
      expose :library_card

      def library_card
        library_card = object.user&.member&.library_cards&.last
        Lms::Entities::LibraryCards.represent(library_card) if library_card.present?
      end
    end
  end
end
