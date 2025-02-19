# frozen_string_literal: true

module ThreePs
  class ReturnOrders < ThreePs::Base

    resources :return_orders do
      route_param :id do
        desc 'Return order receive'

        params do
          requires :status_key, type: String, values: %w[collected_by_3pl]
        end

        patch do
          return_order = ReturnOrder.find_by(id: params[:id])
          if return_order.nil?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Return order not found' },
                                    @current_user, false)
            error!('Return order not found', HTTP_CODE[:NOT_FOUND])
          end
          return_order.update!(return_status_id: ReturnStatus.get_status(params[:status_key]).id)
          ThreePs::Entities::ReturnOrders.represent(return_order)
        end
      end
    end
  end
end
