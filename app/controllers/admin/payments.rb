# frozen_string_literal: true

module Admin
  class Payments < Admin::Base
    include Admin::Helpers::AuthorizationHelpers
    helpers Admin::QueryParams::PaymentParams
    resources :payments do

      desc 'Payments List'
      params do
        use :pagination, per_page: 25
        use :payments_search_params
      end

      get do
        payments = Payment.left_joins(member: %i[user library]).includes(:user, member: :library).distinct
        authorize payments, :read?

        if params[:code].present?
          library = Library.find_by(code: params[:code])
          error!('Library Not found', HTTP_CODE[:NOT_FOUND]) unless library.present?

          payments = payments.where('members.library_id = ?', library.id)
        end
        payments = payments.where('users.phone = ?', params[:phone]) if params[:phone].present?
        payments = payments.send(params[:purpose].to_sym) if params[:purpose].present?
        payments = payments.send(params[:status].to_sym) if params[:status].present?
        payments = payments.send(params[:payment_type].to_sym) if params[:payment_type].present?
        payments = payments.where(trx_id: params[:trx_id]) if params[:trx_id].present?
        payments = payments.where(invoice_id: params[:invoice_id]) if params[:invoice_id].present?
        if params[:start_date].present? && params[:end_date].present?
          payments = payments.where(created_at: (params[:start_date].at_beginning_of_day)..(params[:end_date].at_end_of_day))
        end

        Admin::Entities::Payments.represent(paginate(payments.order(id: :desc)))
      end
      route_param :id do
        desc 'Payment Details'

        get do
          payment = Payment.find_by(id: params[:id])
          error!('Not found', HTTP_CODE[:NOT_FOUND]) unless payment.present?
          authorize payment, :read?
          Admin::Entities::Payments.represent(payment)
        end
      end
    end
  end
end
