# frozen_string_literal: true

module Lms
  class ReturnOrders < Lms::Base
    include Lms::QueryParams::ReturnOrderParams
    resources :return_orders do
      desc 'Return Order list'
      params do
        use :pagination, per_page: 25
      end
      get do
        return_orders = @current_library.return_orders.order(id: :desc)
        paginate(return_orders)
      end

      desc 'Return statuses dropdown List'
      get 'dropdown' do
        statuses = ReturnStatus.order(lms_status: :asc)
        Lms::Entities::ReturnDropdowns.represent(statuses)
      end

      route_param :id do
        desc 'Return Order Details'
        get do
          return_order = @current_library.return_orders.find_by(id: params[:id])
          if return_order.nil?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Return Order Not Found' },
                                    @current_library, false)
            error!('Return Order Not Found', HTTP_CODE[:NOT_FOUND])
          end
          Lms::Entities::ReturnOrder.represent(return_order)
        end

        desc 'Status Update Order'
        params do
          requires :status, type: String, values: ['delivered_to_library'], allow_blank: false
        end
        put :update_status do
          return_order = @current_library.return_orders.find_by(id: params[:id])
          if return_order.nil?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Return Order Not Found' },
                                    @current_library, false)
            error!('Return Order Not Found', HTTP_CODE[:NOT_FOUND])
          end

          status = ReturnStatus.get_status(params[:status])
          if status.nil?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Return Status Not Found' },
                                    @current_library, false)
            error!('Return Status Not Found', HTTP_CODE[:NOT_FOUND])
          end

          if return_order.update!(return_status: status)
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:OK] },
                                    @current_library, true)
            Lms::Entities::ReturnOrder.represent(return_order)
          end
        end
      end
    end
  end
end
