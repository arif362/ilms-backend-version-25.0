module Admin
  module QueryParams
    module IntlResearchGatewayParams
      extend ::Grape::API::Helpers

      params :intl_research_gateway_create_params do
        requires :name, type: String, allow_blank:false
        requires :url, type: String, allow_blank:false
        requires :is_published, type: Boolean, allow_blank:false, values:[true, false]
        requires :is_deleted, type: Boolean, allow_blank:false, values:[true, false]
      end

      params :intl_research_gateway_update_params do
        requires :name, type: String, allow_blank:false
        requires :url, type: String, allow_blank:false
        requires :is_published, type: Boolean, allow_blank:false, values:[true, false]
        requires :is_deleted, type: Boolean, allow_blank:false, values:[true, false]
      end

    end
  end
end