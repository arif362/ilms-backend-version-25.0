# frozen_string_literal: true

module Lms
  class Payments < Lms::Base

    resources :payments do

      resources :membership_requests do
        resources :cash_to_library do

          desc 'Resend an otp for membership security money'
          params do
            requires :membership_request_id, type: Integer, allow_blank: false
            requires :staff_id, type: Integer, allow_blank: false
          end

          post '/resend_otp' do
            staff = @current_library.staffs.library.find_by(id: params[:staff_id])
            if staff.nil?
              LmsLogJob.perform_later(request.headers.merge(params:),
                                      { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff not found' },
                                      @current_library, false)
              error!('Staff not found', HTTP_CODE[:NOT_FOUND])
            end

            membership_request = MembershipRequest.find_by(id: params[:membership_request_id])
            unless membership_request.present?
              LmsLogJob.perform_later(request.headers.merge(params:),
                                      { status_code: HTTP_CODE[:NOT_FOUND], error: 'Membership request not found' },
                                      staff, false)
              error!('Membership request not found', HTTP_CODE[:NOT_FOUND])
            end

            membership_request.otps.create_otp(membership_request.user.phone)
            # send_otp method will apply when sms gateway available from client

            status HTTP_CODE[:OK]
          end


          desc 'Payment for security money'
          params do
            requires :membership_request_id, type: Integer
            requires :staff_id, type: Integer
          end

          post '/security_money' do
            library_staff = @current_library.staffs.library.find_by(id: params[:staff_id])
            unless library_staff.present?
              LmsLogJob.perform_later(request.headers.merge(params:),
                                      { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff not valid for this library' },
                                      @current_library, false)
              error!('Staff not valid for this library', HTTP_CODE[:NOT_FOUND])
            end

            membership_request = MembershipRequest.find_by(id: params[:membership_request_id])
            unless membership_request.present?
              LmsLogJob.perform_later(request.headers.merge(params:),
                                      { status_code: HTTP_CODE[:NOT_FOUND], error: 'Membership request not found' },
                                      library_staff, false)
              error!('Membership request not found', HTTP_CODE[:NOT_FOUND])
            end

            invoice = membership_request.invoices.security_money.pending.last
            unless invoice.present?
              LmsLogJob.perform_later(request.headers.merge(params:),
                                      { status_code: HTTP_CODE[:NOT_FOUND], error: 'No pending invoice found for this security money' },
                                      library_staff, false)
              error!('No pending invoice found for this security money', HTTP_CODE[:NOT_FOUND])
            end

            payment_initialization = PaymentManagement::MembershipRequests::CreatePayment.call(
              invoice:,
              payment_type: :cash,
              status: :pending,
              user: membership_request.user,
              purpose: :security_money
            )

            if payment_initialization.success?
              payment = payment_initialization.payment
              unless payment.present?
                LmsLogJob.perform_later(request.headers.merge(params:),
                                        { status_code: HTTP_CODE[:NOT_FOUND], error: 'Payment not found for this' },
                                        library_staff, false)
                error!('Payment not found for this', HTTP_CODE[:NOT_FOUND])
              end

              payment_finalization = PaymentManagement::MembershipRequests::FinalizePayment.call(
                payment:,
                status: :success,
                library_staff:
              )
              if payment_finalization.success?
                Lms::Entities::Payments.represent(payment)
              else
                Rails.logger.error " Payment not done due to :  #{payment_finalization.full_message}"
                LmsLogJob.perform_later(request.headers.merge(params:),
                                        { status_code: HTTP_CODE[:UNPROCESSABLE_ENTITY], error: payment_finalization.error },
                                        library_staff, false)
                error!(payment_finalization.error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
              end
            else
              LmsLogJob.perform_later(request.headers.merge(params:),
                                      { status_code: HTTP_CODE[:UNPROCESSABLE_ENTITY], error: payment_initialization.error },
                                      library_staff, false)
              error!(payment_initialization.error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end

          end
        end
      end

      desc 'receive a payment for fine with multiple invoice'
      params do
        requires :invoice_ids, type: Array
        requires :member_id, type: Integer
        requires :staff_id, type: Integer
      end

      post '/fines' do
        staff = @current_library.staffs.library.find_by(id: params[:staff_id])
        unless staff.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                  @current_library, false)
          error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
        end
        member = Member.find_by(id: params[:member_id])
        if member.nil?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Member not found' },
                                  @current_library, false)
          error!('Member not found', HTTP_CODE[:NOT_FOUND])
        end
        invoice_ids = member&.user&.invoices&.where(id: params[:invoice_ids])&.where&.not(invoice_status: :paid)&.pluck(:id)
        if invoice_ids.length == 0
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Invoice IDs is not valid' },
                                  @current_library, false)
          error!('Invoices amounts has already been paid', HTTP_CODE[:BAD_REQUEST])
        end
        payment_session = PaymentManagement::Fine::CreatePayment.call(
          invoice_ids:,
          payment_type: :cash,
          status: :pending,
          user: member&.user,
          created_by: staff,
          purpose: :fine
        )

        if payment_session.success?
          payment_session.payment.success!
          Lms::Entities::MultipleInvoicePayments.represent(payment_session.payment)
        else
          error!(payment_session.error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
      end
    end
  end
end
