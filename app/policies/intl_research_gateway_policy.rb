class IntlResearchGatewayPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :INTL_RESEARCH_GATEWAY)
  end
end
