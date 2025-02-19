# frozen_string_literal: true

module PublicLibrary
  class SecurityMoneyRequests < PublicLibrary::Base
    resources :security_money_requests do

      desc 'Security money request list'

      params do
        use :pagination, per_page: 25
      end

      get do
        security_money_requests = @current_user.security_money_requests.order(id: :desc)
        PublicLibrary::Entities::SecurityMoneyRequests.represent(paginate(security_money_requests))
      end

      desc 'Validate security money withdraw request'

      get 'validate' do
        error!('User is not a valid member', HTTP_CODE[:FORBIDDEN]) unless @current_user.member.present?
        validate_params = SecurityWithdrawalManager::SecurityWithdrawalValidator.call(user: @current_user,
                                                                                      is_validator: true)
        if validate_params.success?
          security_moneys = @current_user.security_moneys.available
          error!('Security money not available', HTTP_CODE[:NOT_ACCEPTABLE]) if security_moneys.empty?
          PublicLibrary::Entities::SecurityMoneys.represent(security_moneys)
        else
          status HTTP_CUSTOM_CODE[:NOT_ELIGIBLE]
          validate_params.error
        end
      end

      desc 'Apply Security Money to withdraw'

      params do
        requires :password, type: String, allow_blank: false
        optional :phone, type: String, allow_blank: false, regexp: /(\A(\+88|0088)?(01)[3456789](\d){8})\z/
      end

      post do
        error!('User is not a valid member', HTTP_CODE[:FORBIDDEN]) unless @current_user.member.present?
        error!('Incorrect password', HTTP_CODE[:FORBIDDEN]) unless @current_user.password == params[:password]
        grouped_security_moneys = @current_user.security_moneys.available.group_by(&:payment_method)
        if grouped_security_moneys['online'].present? && params[:phone].blank?
          error!('Phone required for nagad payment', HTTP_CODE[:BAD_REQUEST])
        end
        validate_params = SecurityWithdrawalManager::SecurityWithdrawalValidator.call(user: @current_user,
                                                                                      is_validator: false)
        error!(validate_params.error, HTTP_CODE[:NOT_ACCEPTABLE]) unless validate_params.error.empty?

        security_money_requests = []
        grouped_security_moneys.each do |key, value|
          payment_method = key == 'cash' ? SecurityMoneyRequest.payment_methods[:pickup_from_library] : SecurityMoneyRequest.payment_methods[:nagad_payment]
          security_money_request = @current_user.security_money_requests.new(library_id: @current_user.member.library.id,
                                                                             payment_method:,
                                                                             amount: value.sum(&:amount),
                                                                             created_by: @current_user,
                                                                             updated_by: @current_user)
          security_money_request.phone = params[:phone] if params[:phone].present? && key != 'cash'
          security_money_requests << security_money_request if security_money_request.save!
        end
        PublicLibrary::Entities::SecurityMoneyRequests.represent(security_money_requests)
      end

      desc 'Security money request details'
      get '/latest' do
        security_money_request = @current_user.security_money_requests.last
        error!('Security money request not found', HTTP_CODE[:NOT_FOUND]) unless security_money_request.present?
        PublicLibrary::Entities::SecurityMoneyRequestDetails.represent(security_money_request)
      end
    end
  end
end
