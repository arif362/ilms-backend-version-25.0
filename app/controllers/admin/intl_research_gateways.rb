module Admin
  class IntlResearchGateways < Base
    include Admin::Helpers::AuthorizationHelpers
    helpers Admin::QueryParams::IntlResearchGatewayParams

    resources :intl_research_gateways do

      desc 'get intl research gateways list'
      params do
        use :pagination, max_per_page:25
      end
      get do
        intl_research_gateways = IntlResearchGateway.where(is_deleted:false)
          authorize intl_research_gateways, :read?
        Admin::Entities::IntlResearchGateways.represent(paginate(intl_research_gateways))
      end


      desc 'create intl research gateway'
      params do
        use :intl_research_gateway_create_params
      end
      post do
        intl_research_gateway = IntlResearchGateway.create!(declared(params, include_missing:false)
                                                              .merge(created_by: @current_staff.id, updated_by: @current_staff.id))
          authorize intl_research_gateway, :create?
        Admin::Entities::IntlResearchGateways.represent(intl_research_gateway)
      end

      route_param :id do

        desc "get intl research gateway details"
        get do
          intl_research_gateway = IntlResearchGateway.find_by(id:params[:id])
          error!("Not Found", HTTP_CODE[:NOT_FOUND]) unless intl_research_gateway.present?
           authorize intl_research_gateway, :read?
          Admin::Entities::IntlResearchGateways.represent(intl_research_gateway)
        end

        desc "update intl research gateway"
        params do
          use :intl_research_gateway_update_params
        end
        put do
          intl_research_gateway = IntlResearchGateway.find_by(id:params[:id])
          error!("Not Found", HTTP_CODE[:NOT_FOUND]) unless intl_research_gateway.present?
           authorize intl_research_gateway, :update?
          intl_research_gateway.update!(declared(params, include_missing:false).merge(updated_by:@current_staff.id))
          Admin::Entities::IntlResearchGateways.represent(intl_research_gateway)
        end

        desc "delete intl research gateway"
        delete do
          intl_research_gateway = IntlResearchGateway.find_by(id:params[:id])
          error!("Not found", HTTP_CODE[:NOT_FOUND]) unless  intl_research_gateway.present?
           authorize intl_research_gateway, :delete?
          intl_research_gateway.update!(is_deleted: true)
          status HTTP_CODE[:OK]
        end
      end
    end
  end
end