class PublisherPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :PUBLISHER)
  end
end
