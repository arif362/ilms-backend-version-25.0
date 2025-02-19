# frozen_string_literal: true

module PublicLibrary
  class Payments < PublicLibrary::Base
    helpers PublicLibrary::Helpers::PaymentHelper
    resources :payments do

      desc 'Payments List'
      params do
        use :pagination, per_page: 25
        optional :status, type: String, values: Payment.statuses.keys
        optional :purpose, type: String, values: Payment.purposes.keys
      end

      get do
        payments = params[:purpose].present? ? @current_user.payments.send(params[:purpose].to_sym) : @current_user.payments
        PublicLibrary::Entities::Payments.represent(paginate(payments.order(id: :desc)))
      end

      resources :nagad do
        desc 'Complete a payment through Nagad'
        params do
          requires :invoice_id, type: Integer
          requires :ip_address, type: String
        end

        post '/initiate' do
          invoice = @current_user.invoices.pending.find_by(id: params[:invoice_id])
          unless invoice.present?
            error!("Invoice not found for pending #{params[:invoice_type]}", HTTP_CODE[:NOT_FOUND])
          end

          payment_session = PaymentManagement::Nagad::CompletePayment.call(
            invoice:,
            ip_address: params[:ip_address],
            payment_type: :nagad,
            status: :pending,
            user: @current_user,
            purpose: invoice.invoice_type
          )

          if payment_session.success?
            data = { redirect_url: payment_session.callback_url }
            status HTTP_CODE[:OK]
            data
          else
            error!(payment_session.error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        params do
          requires :invoice_id, type: Integer
        end

        patch '/cancel' do
          invoice = @current_user.invoices.pending.find_by(id: params[:invoice_id])
          error!('Invoice not found', HTTP_CODE[:NOT_FOUND]) unless invoice.present?
          pending_payment = invoice.payments.pending.last
          if pending_payment.present?
            invoice.payments.pending.last.cancelled!
            { success: true, message: 'Pending payments associated to the invoice is cancelled.' }
          else
            error!('No pending payment found for this invoice', HTTP_CODE[:NOT_FOUND])
          end
        end

        desc 'Verify Nagad payment.'
        params do
          requires :payment_id, type: Integer
          requires :ip_address, type: String
          requires :payment_reference_id, type: String
        end
        post '/verify' do
          Rails.logger.info "Nagad Verify params #{params}"
          payment = @current_user.payments.pending.find_by(id: params[:payment_id])
          error!('Payment transaction not found', HTTP_CODE[:NOT_FOUND]) unless payment.present?

          payment_verification = PaymentManagement::Nagad::VerifyPayment.call(
            payment:,
            ip_address: params[:ip_address],
            payment_reference_id: params[:payment_reference_id]
          )
          if payment_verification.success?
            status HTTP_CODE[:OK]
            { payment: payment.id }
          else
            error!(payment_verification.error&.to_s, HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        resources :fine do
          desc 'Initiate a payment for fine'
          params do
            requires :invoice_ids, type: Array
            requires :ip_address, type: String
          end

          post '/initiate' do
            payment_session = PaymentManagement::Nagad::CompleteFinePayment.call(
              invoice_ids: params[:invoice_ids],
              ip_address: params[:ip_address],
              payment_type: :nagad,
              status: :pending,
              user: @current_user,
              created_by: @current_user,
              purpose: :fine
            )

            if payment_session.success?
              data = { redirect_url: payment_session.callback_url }
              status HTTP_CODE[:OK]
              data
            else
              error!(payment_session.error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end
          end
        end

      end
    end
  end
end
