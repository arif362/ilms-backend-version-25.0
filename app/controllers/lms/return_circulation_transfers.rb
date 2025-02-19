# frozen_string_literal: true

module Lms
  class ReturnCirculationTransfers < Lms::Base
    resources :return_circulation_transfers do

      route_param :id do
        params do
          requires :staff_id, type: Integer
        end
        desc 'In-progress status update of return circulation transfer'
        put 'in_progress' do
          staff = @current_library.staffs.library.find_by(id: params[:staff_id])
          unless staff.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                    @current_library, false)
            error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
          end

          return_circulation_transfer = ReturnCirculationTransfer.find_by(sender_library_id: @current_library.id,
                                                                          id: params[:id])
          if return_circulation_transfer.nil?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Return Circulation Transfer Not Found' },
                                    staff, false)
            error!('Return Circulation Transfer Not Found', HTTP_CODE[:NOT_FOUND])
          end

          status = ReturnCirculationStatus.get_status(:in_progress)
          if status.nil?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Return Circulation Status Not Found' },
                                    staff, false)
            error!('Return Circulation Status Not Found', HTTP_CODE[:NOT_FOUND])
          end

          if return_circulation_transfer.update!(return_circulation_status_id: status&.id)
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:OK] },
                                    staff, true)
            Lms::Entities::ReturnCirculationTransfer.represent(return_circulation_transfer)
          end
        end

        desc 'Delivered status update of return circulation transfer'
        params do
          requires :staff_id, type: Integer
        end
        put 'delivered' do
          staff = @current_library.staffs.library.find_by(id: params[:staff_id])
          unless staff.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                    @current_library, false)
            error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
          end

          return_circulation_transfer = ReturnCirculationTransfer.find_by(receiver_library_id: @current_library.id,
                                                                          id: params[:id])
          if return_circulation_transfer.nil?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Return Circulation Transfer Not Found' },
                                    staff, false)
            error!('Return Circulation Transfer Not Found', HTTP_CODE[:NOT_FOUND])
          end

          status = ReturnCirculationStatus.get_status(:delivered)
          if status.nil?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Return Circulation Status Not Found' },
                                    staff, false)
            error!('Return Circulation Status Not Found', HTTP_CODE[:NOT_FOUND])
          end

          if return_circulation_transfer.update!(return_circulation_status_id: status&.id)
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:OK] },
                                    staff, true)
            Lms::Entities::ReturnCirculationTransfer.represent(return_circulation_transfer)
          end
        end
      end
    end
  end
end
