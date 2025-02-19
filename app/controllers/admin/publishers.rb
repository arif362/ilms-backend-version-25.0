# frozen_string_literal: true

module Admin
  class Publishers < Admin::Base
    include Admin::Helpers::AuthorizationHelpers

    resource :publishers do
      desc 'Get a list of memorandums'
      params do
        use :pagination, per_page: 25
      end
      get do
        publishers = Publisher.includes(:user).all
        authorize publishers, :read?
        Admin::Entities::Publishers.represent(publishers)
      end
    end
  end
end
