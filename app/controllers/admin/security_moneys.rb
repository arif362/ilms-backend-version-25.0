# frozen_string_literal: true

module Admin
  class SecurityMoneys < Admin::Base
    resources :security_moneys do
      include Admin::Helpers::AuthorizationHelpers

      desc 'Security money List'
      params do
        use :pagination, max_per_page: 25
        optional :status, type: String, values: SecurityMoney.statuses.keys
      end

      get do
        security_moneys = SecurityMoney.all
        security_moneys = security_moneys.send(params[:status]) if params[:status].present?
        authorize security_moneys, :read?
        Admin::Entities::SecurityMoney.represent(paginate(security_moneys.order(id: :desc)))
      end

      route_param :id do
        desc 'Security Money Details'
        get do
          security_money = SecurityMoney.find_by(id: params[:id])
          error!('Not Found', 404) unless security_money.present?

          authorize security_money, :read?
          Admin::Entities::SecurityMoney.represent(security_money)
        end
      end
    end
  end
end
