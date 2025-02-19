module PublicLibrary
  class IntlResearchGateways < PublicLibrary::Base
    resources :intl_research_gateways do
      desc ' get active international research gateway list'
      params do
        use :pagination, max_per_page: 25
      end
      route_setting :authentication, optional: true
      get do
        intl_research_gateways = IntlResearchGateway.active
        Admin::Entities::IntlResearchGateways.represent(paginate(intl_research_gateways))
      end

    end
  end
end