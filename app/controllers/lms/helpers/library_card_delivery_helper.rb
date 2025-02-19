# frozen_string_literal: true

module Lms
  module Helpers
    module LibraryCardDeliveryHelper
      extend Grape::API::Helpers

      def validate_home_delivery_address(params, member, staff)
        unless params[:delivery_address_type].present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:BAD_REQUEST], error: 'Delivery address type is required' },
                                  staff, false)
          error!('Delivery address type is required', HTTP_CODE[:BAD_REQUEST])
        end
        if params[:is_self_recipient] == false && params[:recipient_name].blank?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:BAD_REQUEST], error: 'Recipient name is required' },
                                  staff, false)
          error!('Recipient name is required', HTTP_CODE[:BAD_REQUEST])
        end
        if params[:is_self_recipient] == false && params[:recipient_phone].blank?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:BAD_REQUEST], error: 'Recipient phone is required' },
                                  staff, false)
          error!('Recipient phone is required', HTTP_CODE[:BAD_REQUEST])
        end
        delivery_address = {}
        if params[:delivery_address_type] == 'others'
          unless params[:delivery_address].present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:BAD_REQUEST],
                                      error: 'Recipient delivery address is required' },
                                    staff, false)
            error!('Recipient delivery address is required', HTTP_CODE[:BAD_REQUEST])
          end
          unless params[:delivery_division_id].present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:BAD_REQUEST],
                                      error: 'Recipient delivery division is required' },
                                    staff, false)
            error!('Recipient delivery division is required', HTTP_CODE[:BAD_REQUEST])
          end
          unless params[:delivery_district_id].present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:BAD_REQUEST],
                                      error: 'Recipient delivery district is required' },
                                    staff, false)
            error!('Recipient delivery district is required', HTTP_CODE[:BAD_REQUEST])
          end
          unless params[:delivery_thana_id].present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:BAD_REQUEST],
                                      error: 'Recipient delivery thana is required' },
                                    staff, false)
            error!('Recipient delivery thana is required', HTTP_CODE[:BAD_REQUEST])

            thana = Thana.find_by(id: params[:delivery_thana_id])
            unless thana.present?
              LmsLogJob.perform_later(request.headers.merge(params:),
                                      { status_code: HTTP_CODE[:NOT_FOUND], error: 'Thana not found' },
                                      staff, false)
              error!('Thana not found', HTTP_CODE[:NOT_FOUND])
            end

            delivery_address[:library_id] = thana&.library.present? ? thana&.library : thana.district.library_from_district(thana)
          end
        elsif params[:delivery_address_type] == 'permanent'
          delivery_address[:delivery_address] = member.permanent_address
          delivery_address[:delivery_division_id] = member.permanent_division_id
          delivery_address[:delivery_district_id] = member.permanent_district_id
          delivery_address[:delivery_thana_id] = member.permanent_thana_id
          delivery_address[:library_id] =
            member.permanent_thana&.library.present? ? member.permanent_thana&.library : member.permanent_thana.district.library_from_district(member.permanent_thana)
        else
          delivery_address[:delivery_address] = member.present_address
          delivery_address[:delivery_division_id] = member.present_division_id
          delivery_address[:delivery_district_id] = member.present_district_id
          delivery_address[:delivery_thana_id] = member.present_thana_id
          delivery_address[:library_id] =
            member.present_thana&.library.present? ? member.present_thana&.library : member.present_thana.district.library_from_district(member.present_thana)
        end
        delivery_address.merge!(recipient_name: params[:is_self_recipient] ? member.user.full_name : params[:recipient_name],
                                recipient_phone: params[:is_self_recipient] ? member.user.phone : params[:recipient_phone])
      end
    end
  end
end
