# frozen_string_literal: true

module Admin
  class FailedSearches < Admin::Base
    resources :failed_searches do
      include Admin::Helpers::AuthorizationHelpers
      desc 'failed searches List'
      params do
        use :pagination, per_page: 25
        optional :keyword, type: String
      end
      get do
        failed_searches = FailedSearch.all
        unless params[:keyword].blank?
          failed_searches = failed_searches.where('lower(keyword) like ?', "%#{params[:keyword].downcase}%")
        end
        authorize failed_searches, :read?
        Admin::Entities::FailedSearches.represent(paginate(failed_searches.order(id: :desc)))
      end
    end
  end
end
