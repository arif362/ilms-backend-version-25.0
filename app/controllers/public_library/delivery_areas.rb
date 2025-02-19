# frozen_string_literal: true

module PublicLibrary
  class DeliveryAreas < PublicLibrary::Base
    resources :delivery_areas do
      desc 'Delivery Areas List'
      params do
        use :pagination, per_page: 25
        requires :district_id, type: Integer
      end
      route_setting :authentication, optional: true
      get do
        district = District.find_by(id: params[:district_id])
        error!("District not found for id #{params[:district_id]}", HTTP_CODE[:NOT_FOUND]) unless district.present?

        redx_areas = ParcelManagement::Areas::GetAreas.call(
          post_code: params[:post_code],
          district_name: district.name,
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
