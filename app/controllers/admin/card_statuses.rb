# frozen_string_literal: true

module Admin
  class CardStatuses < Admin::Base
    resources :card_statuses do

      desc 'card_statuses dropdown List'

      get 'dropdown' do
        card_statuses = CardStatus.all.order(id: :asc)
        Admin::Entities::CardStatus.represent(card_statuses)
      end
    end
  end
end
