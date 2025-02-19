# frozen_string_literal: true

module Admin
  class SecurityMoneyRequests < Admin::Base
    resources :security_money_requests do
      include Admin::Helpers::AuthorizationHelpers

      desc 'Security money withdraw request list'
      params do
        use :pagination, max_per_page: 25
        optional :status, type: String, values: SecurityMoneyRequest.statuses.keys
        optional :library_code, type: String
        optional :start_date, type: DateTime
        optional :end_date, type: DateTime
        optional :phone, type: String
      end

      get do
        security_money_requests = SecurityMoneyRequest.left_joins(%i[user library]).includes(:user, :library).distinct
        if params[:phone].present?
          security_money_requests = security_money_requests.where('users.phone = ?', params[:phone])
        end
        security_money_requests = security_money_requests.send(params[:status]) if params[:status].present?

        if params[:start_date].present? && params[:end_date].present?
          security_money_requests = security_money_requests.where(created_at: (params[:start_date].at_beginning_of_day)..(params[:end_date].at_end_of_day))
        end

        if params[:library_code].present?
          library = Library.find_by(code: params[:library_code])
          error!('Library not found', 404) unless library.present?
          security_money_requests = security_money_requests.where('libraries.id = ?', library.id) if library.present?
        end
        authorize security_money_requests, :read?
        Admin::Entities::SecurityMoneyRequest.represent(paginate(security_money_requests.order(id: :desc)))
      end

      route_param :id do
        desc 'Security Money withdraw request Details'
        get do
          security_money_request = SecurityMoneyRequest.find_by(id: params[:id])
          error!('Not Found', 404) unless security_money_request.present?

          authorize security_money_request, :read?
          Admin::Entities::SecurityMoneyRequest.represent(security_money_request)
        end
      end
    end
  end
end
