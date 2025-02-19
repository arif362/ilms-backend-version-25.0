class CollectionsPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :COLLECTION)
  end
end