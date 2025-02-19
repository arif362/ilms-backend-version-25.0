# frozen_string_literal: true

module LibraryCardService
  class DeliveryAddressValidation
    include Interactor

    delegate :request_params, :membership_request, to: :context

    def call
      card_delivery_address_validation(membership_request.request_detail)
      update_invoice_and_request_details(membership_request.request_detail)
    end

    private

    def card_delivery_address_validation(request_detail)
      context.fail!(error: 'Recipient Name is Required') unless request_params[:recipient_name].present?
      context.fail!(error: 'Recipient Phone is Required') unless request_params[:recipient_phone].present?

      case request_params[:delivery_address_type]
      when 'others'
        other_delivery_address_validation
      when 'present'
        present_delivery_address_validation(request_detail)
      when 'permanent'
        parmanent_delivery_address_validation(request_detail)
      end
    end

    def other_delivery_address_validation
      context.fail!(error: 'Delivery Address is Required') unless request_params[:delivery_address].present?
      context.fail!(error: 'Delivery Division ID is Required') unless request_params[:delivery_division_id].present?
      context.fail!(error: 'Delivery District ID Required') unless request_params[:delivery_district_id].present?
      context.fail!(error: 'Delivery Thana Required') unless request_params[:delivery_thana_id].present?
    end

    def present_delivery_address_validation(request_detail)
      request_params[:delivery_address] = request_params[:delivery_address].present? || request_detail.present_address
      request_params[:delivery_division_id] = request_params[:delivery_division_id].present? || request_detail.present_division_id
      request_params[:delivery_district_id] = request_params[:delivery_district_id].present? || request_detail.present_district_id
      request_params[:delivery_thana_id] = request_params[:delivery_thana_id].present? || request_detail.present_thana_id
    end

    def parmanent_delivery_address_validation(request_detail)
      request_params[:delivery_address] = request_params[:delivery_address].present? || request_detail.permanent_address
      request_params[:delivery_division_id] = request_params[:delivery_division_id].present? || request_detail.permanent_division_id
      request_params[:delivery_district_id] = request_params[:delivery_district_id].present? || request_detail.permanent_district_id
      request_params[:delivery_thana_id] = request_params[:delivery_thana_id].present? || request_detail.permanent_thana_id
    end

    def update_invoice_and_request_details(request_detail)


      district = District.find_by(id: request_params[:delivery_district_id])
      delivery_charge = calculate_card_delivery_charge(membership_request, district)
      invoice = request_detail.membership_request.invoices.security_money.pending.last
      invoice.update!(invoice_amount: security_money_calculation(request_detail).to_i + delivery_charge.to_i)
    end

    def calculate_card_delivery_charge(membership_request, district)
      if membership_request.request_detail.library.district == district
        ENV['SHIPPING_CHARGE_SAME_DISTRICT']
      else
        ENV['SHIPPING_CHARGE_OTHER_DISTRICT']
      end
    end

    def security_money_calculation(request_detail)
      if request_detail.general?
        ENV['GENERAL_MBR_SECURITY_MONEY']
      elsif request_detail.student?
        ENV['STUDENT_MBR_SECURITY_MONEY']
      elsif request_detail.child?
        ENV['CHILD_MBR_SECURITY_MONEY']
      end
    end
  end
end
