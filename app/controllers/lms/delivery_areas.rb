# frozen_string_literal: true

module Lms
  class DeliveryAreas < Lms::Base
    resources :delivery_areas do
      desc 'Delivery Areas List'
      params do
        requires :district_name, type: String
      end
      route_setting :authentication, optional: true
      get do
        redx_areas = ParcelManagement::Areas::GetAreas.call(
          post_code: params[:post_code],
          district_name: params[:district_name],
          zone_id: params[:zone_id]
        )

        if redx_areas.success?
          status HTTP_CODE[:OK]
          redx_areas.areas
        else
          error!(redx_areas.error&.to_s, HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

      end
    end
  end
end
