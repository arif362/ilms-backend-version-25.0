# frozen_string_literal: true

module Admin
  class LibraryCards < Admin::Base
    include Admin::Helpers::AuthorizationHelpers

    resources :library_cards do
      desc 'Card Requests'
      params do
        use :pagination, max_per_page: 25
        optional :status_id, type: Integer, allow_blank: false
        optional :delivery_type, type: String, values: LibraryCard.delivery_types.keys, allow_blank: false
        optional :member_id, type: String, allow_blank: false
        optional :library_id, type: Integer, allow_blank: false
      end

      get do
        cards = LibraryCard.all
        authorize cards, :read?
        if params[:member_id].present?
          cards = LibraryCard.joins(:member).where('members.id = ?', params[:member_id][2..].to_i)
        end
        if params[:library_id].present?
          library = Library.find_by(id: params[:library_id])
          error!('Library not found', HTTP_CODE[:NOT_FOUND]) if library.nil?
          cards = cards.where(issued_library_id: library&.id)
        end
        cards = cards.where(card_status_id: params[:status_id]) if params[:status_id].present?
        cards = cards.where(delivery_type: params[:delivery_type]) if params[:delivery_type].present?
        Admin::Entities::LibraryCards.represent(paginate(cards.order(id: :desc)))
      end

      route_param :id do
        desc 'Card Request Details'
        get do
          card = LibraryCard.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) if card.nil?
          authorize card, :read?
          Admin::Entities::LibraryCardDetails.represent(card)
        end

        desc 'Card Request Status Update'
        params do
          requires :card_status_id, type: Integer, allow_blank: false
        end
        put do
          card = LibraryCard.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) if card.nil?
          authorize card, :update?

          status = CardStatus.find_by(id: params[:card_status_id])
          error!('Card Status Not Found', HTTP_CODE[:NOT_FOUND]) if status.nil?

          card.update!(card_status_id: status.id, updated_by: @current_staff)
          Admin::Entities::LibraryCards.represent(card)
        end
      end
    end
  end
end