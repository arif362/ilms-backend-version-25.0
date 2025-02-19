# frozen_string_literal: true

module Lms
  class SecurityMoneyRequests < Lms::Base

    resources :security_money_requests do
      desc 'Security Money Requests'

      params do
        use :pagination, max_per_page: 25
      end

      get do
        security_money_requests = SecurityMoneyRequest.all.order(id: :desc)
        Lms::Entities::SecurityMoneyRequests.represent(paginate(security_money_requests))
      end

      desc 'Validate security money withdraw request'
      params do
        requires :staff_id, type: Integer
        requires :member_id, type: Integer
      end

      get 'validate' do
        staff = @current_library.staffs.find_by(id: params[:staff_id])
        unless staff.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff not valid for this library' },
                                  @current_library, false)
          error!('Staff not valid for this library', HTTP_CODE[:NOT_FOUND])
        end
        member = Member.find_by(id: params[:member_id])
        unless member.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:FORBIDDEN], error: 'Member not found' },
                                  staff,
                                  false)
          error!('Member not found', HTTP_CODE[:FORBIDDEN])
        end
        user = member.user
        validate_params = SecurityWithdrawalManager::SecurityWithdrawalValidator.call(user:,
                                                                                      is_validator: true)
        if validate_params.success?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:OK] },
                                  staff, true)
          grouped_security_moneys = user.security_moneys.available.group_by(&:payment_method)
          if grouped_security_moneys.empty?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Not a member' },
                                    staff, false)
            error!('Not a member', HTTP_CODE[:NOT_ACCEPTABLE])
          end
          security_moneys = []
          grouped_security_moneys.each { |key, val| security_moneys << { payment_method: key, amount: val.sum(&:amount) } }
          if member.library != @current_library
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_ACCEPTABLE],
                                      error: 'Not a member of current library' },
                                    staff, false)
            {
              library: Lms::Entities::Libraries.represent(member.library),
              security_moneys: Lms::Entities::SecurityMoneys.represent(security_moneys)
            }
          else
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:OK] },
                                    staff, true)
            { security_moneys: Lms::Entities::SecurityMoneys.represent(security_moneys) }
          end
        else
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: validate_params.error },
                                  staff, false)
          status HTTP_CODE[:NOT_ACCEPTABLE]
          validate_params.error
        end
      end

      desc 'resend otp for security money withdraw request'
      params do
        requires :staff_id, type: Integer
        requires :member_id, type: Integer
      end

      post 'resend_otp' do
        staff = @current_library.staffs.find_by(id: params[:staff_id])
        unless staff.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff not valid for this library' },
                                  @current_library, false)
          error!('Staff not valid for this library', HTTP_CODE[:NOT_FOUND])
        end
        member = Member.find_by(id: params[:member_id])
        unless member.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Member not found' },
                                  staff,
                                  false)
          error!('Member not found', HTTP_CODE[:NOT_FOUND])
        end
        user = member.user
        otp = user.otps.security_money_withdraw.create_otp(user.phone)
        unless otp.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:BAD_REQUEST], error: 'Otp send failed' },
                                  staff,
                                  false)
          error!('Otp send failed', HTTP_CODE[:BAD_REQUEST])
        end
        LmsLogJob.perform_later(request.headers.merge(params:),
                                { status_code: HTTP_CODE[:CREATED] },
                                staff, true)
        status HTTP_CODE[:CREATED]
      end

      desc 'Apply Security Money to withdraw'

      params do
        requires :staff_id, type: Integer
        requires :member_id, type: Integer
        # online withdrawal from lms need confirmation
        # optional :phone, type: String, allow_blank: false, regexp: /(\A(\+88|0088)?(01)[3456789](\d){8})\z/
      end

      post do
        staff = @current_library.staffs.find_by(id: params[:staff_id])
        unless staff.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                  @current_library,
                                  false)
          error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
        end
        member = Member.find_by(id: params[:member_id])
        unless member.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:FORBIDDEN], error: 'Member not found' },
                                  staff,
                                  false)
          error!('Member not found', HTTP_CODE[:FORBIDDEN])
        end
        if member.library != @current_library
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:BAD_REQUEST],
                                    error: 'Not a member of current library' },
                                  staff, false)
          error!('Not a member of current library', HTTP_CODE[:BAD_REQUEST])
        end
        user = member.user
        cash_security_moneys = user.security_moneys.available.cash
        unless cash_security_moneys.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'No available cash security money' },
                                  staff,
                                  false)
          error!('No available cash security money', HTTP_CODE[:NOT_ACCEPTABLE])
        end
        # online withdrawal from lms need confirmation
        # grouped_security_moneys = user.security_moneys.available.group_by(&:payment_method)
        # if grouped_security_moneys['online'].present? && params[:phone].blank?
        #   LmsLogJob.perform_later(request.headers.merge(params:),
        #                           { status_code: HTTP_CODE[:BAD_REQUEST], error: 'Phone required for online payment' },
        #                           staff,
        #                           false)
        #   error!('Phone required for online payment', HTTP_CODE[:BAD_REQUEST])
        # end
        validate_params = SecurityWithdrawalManager::SecurityWithdrawalValidator.call(user:,
                                                                                      is_validator: false)
        unless validate_params.error.empty?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: validate_params.error },
                                  staff,
                                  false)
          error!({ errors: validate_params.error }, HTTP_CODE[:NOT_ACCEPTABLE])
        end

        security_money_request = user.security_money_requests.new(library_id: member.library.id,
                                                                  payment_method: SecurityMoneyRequest.payment_methods[:pickup_from_library],
                                                                  amount: cash_security_moneys.sum(&:amount),
                                                                  created_by: staff,
                                                                  updated_by: staff)
        if security_money_request.save!
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:CREATED] },
                                  staff,
                                  true)
        else
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:BAD_REQUEST],
                                    error: 'Failed to create security money request' },
                                  staff,
                                  false)
          error!('Failed to create security money request', HTTP_CODE[:BAD_REQUEST])
        end

        # security_money_requests = []
        # grouped_security_moneys.each do |key, value|
        #   payment_method = key == 'cash' ? SecurityMoneyRequest.payment_methods[:pickup_from_library] : SecurityMoneyRequest.payment_methods[:nagad_payment]
        #   security_money_request = user.security_money_requests.new(library_id: member.library.id,
        #                                                             payment_method:,
        #                                                             amount: value.sum(&:amount),
        #                                                             created_by: staff,
        #                                                             updated_by: staff)
        #   security_money_request.phone = params[:phone] if params[:phone].present? && key != 'cash'
        #   if security_money_request.save!
        #     LmsLogJob.perform_later(request.headers.merge(params:, security_money_request:),
        #                             { status_code: HTTP_CODE[:CREATED] },
        #                             staff,
        #                             true)
        #     security_money_requests << security_money_request
        #   else
        #     LmsLogJob.perform_later(request.headers.merge(params:),
        #                             { status_code: HTTP_CODE[:BAD_REQUEST],
        #                               error: 'Failed to create security money request' },
        #                             staff,
        #                             false)
        #     error!('Failed to create security money request', HTTP_CODE[:BAD_REQUEST])
        #   end
        # end
        # otp = user.otps.security_money_withdraw.create_otp(user.phone)
        # if otp.present?
        #   LmsLogJob.perform_later(request.headers.merge(params:),
        #                           { status_code: HTTP_CODE[:CREATED] },
        #                           staff, true)
        # else
        #   LmsLogJob.perform_later(request.headers.merge(params:),
        #                           { status_code: HTTP_CODE[:BAD_REQUEST], error: 'Otp send failed' },
        #                           staff, false)
        # end
        Lms::Entities::SecurityMoneyRequests.represent(security_money_request)
      end

      desc 'Security Money Request verify otp only for lms'
      params do
        requires :staff_id, type: Integer
        requires :otp, type: String, allow_blank: false
        requires :member_id, type: Integer
      end

      put 'otp/verify' do
        staff = @current_library.staffs.find_by(id: params[:staff_id])
        unless staff.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                  @current_library,
                                  false)
          error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
        end
        member = Member.find_by(id: params[:member_id])
        user = member.user
        unless member.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:FORBIDDEN], error: 'Member not found' },
                                  staff,
                                  false)
          error!('Member not found', HTTP_CODE[:FORBIDDEN])
        end
        security_money_request = @current_library.security_money_requests.available_to_withdraw.pickup_from_library
                                                 .find_by(user_id: user.id)
        unless security_money_request.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND],
                                    error: 'No available pickup from library request found for this library' },
                                  staff, false)
          error!('No available pickup from library request found for this library', HTTP_CODE[:NOT_FOUND])
        end
        otp = user.otps.security_money_withdraw.active.where(code: params[:otp])&.last
        unless otp.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_ACCEPTABLE],
                                    error: 'Otp not matched. Please resend otp again' },
                                  staff, false)
          error!('Otp not matched. Please resend otp again', HTTP_CODE[:NOT_ACCEPTABLE])
        end
        if otp.expired?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Expired OTP' },
                                  staff, false)
          error!('Expired OTP', HTTP_CODE[:NOT_ACCEPTABLE])
        end
        otp.update!(is_otp_verified: true)
        LmsLogJob.perform_later(request.headers.merge(params:),
                                { status_code: HTTP_CODE[:OK] },
                                staff, true)

        security_money_request.update!(status: :withdrawn, updated_by: staff, last_updated_by_id: staff.id)
        LmsLogJob.perform_later(request.headers.merge(params:, security_money_request:),
                                { status_code: HTTP_CODE[:OK] },
                                staff, true)
        Lms::Entities::SecurityMoneyRequests.represent(security_money_request)
      end

      route_param :id do
        desc 'Security Money Request Details'
        get do
          security_money_request = SecurityMoneyRequest.find_by(id: params[:id])
          unless security_money_request.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Not Found' },
                                    @current_library, false)
            error!('Not Found', HTTP_CODE[:NOT_FOUND])
          end
          Lms::Entities::SecurityMoneyRequests.represent(security_money_request)
        end

        desc 'Security Money Request Request Accept Reject'
        params do
          requires :staff_id, type: Integer
          requires :status, type: String, values: %w[approved rejected available_to_withdraw], allow_blank: false
          optional :note, type: String, allow_blank: false
        end

        put 'accept_reject' do
          staff = @current_library.staffs.find_by(id: params[:staff_id])
          unless staff.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                    @current_library,
                                    false)
            error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
          end
          security_money_request = @current_library.security_money_requests.find_by(id: params[:id])
          error!('Request not found', HTTP_CODE[:NOT_FOUND]) unless security_money_request.present?
          unless security_money_request.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND],
                                      error: 'Request not found for this library' },
                                    staff, false)
            error!('Request not found for this library', HTTP_CODE[:NOT_FOUND])
          end
          if params[:status] == 'rejected' && !params[:note].present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:BAD_REQUEST], error: 'Specify reject reason' },
                                    staff, false)
            error!('Specify reject reason', HTTP_CODE[:BAD_REQUEST])
          end
          unless security_money_request.validate_status_update(params[:status])
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:BAD_REQUEST],
                                      error: "#{security_money_request.status} can't be updated to  #{params[:status]}" },
                                    staff, false)
            error!("#{security_money_request.status} can't be updated to  #{params[:status]}", HTTP_CODE[:BAD_REQUEST])
          end
          security_money_request.update!(declared(params, include_missing: false).except(:staff_id)
                                                                                 .merge(updated_by: staff))
          Lms::Entities::SecurityMoneyRequests.represent(security_money_request)
        end
      end
    end
  end
end
