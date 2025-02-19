# frozen_string_literal: true

module ThreePs
  class LibraryCards < ThreePs::Base

    resources :library_cards do
      route_param :id do
        desc 'library card status update home'

        params do
          requires :status_key, type: String, values: %w[delivered]
        end

        patch do
          card = LibraryCard.find_by(id: params[:id],
                                     card_status_id: CardStatus.get_status('collected_by_3pl').id)
          if card.nil?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Card not found' },
                                    @current_user, false)
            error!('Card not found', HTTP_CODE[:NOT_FOUND])
          end
          error!('Only home delivery type is accepted', HTTP_CODE[:NOT_ACCEPTED]) unless card.home_delivery?
          card.update!(card_status_id: CardStatus.get_status(params[:status_key]).id, updated_by: @current_user)
          # update the sender library
          Lms::CardPrintManagement::IssuedLibraryDeliverStatusJob.perform_later(card, @current_user)
          #  update the printing library
          Lms::CardPrintManagement::IncomingStatusUpdateJob.perform_later(card, params[:status_key], @current_user)
          ThreePs::Entities::LibraryCards.represent(card)
        end
      end

    end
  end
end
