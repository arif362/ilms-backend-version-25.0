class MemorandumPublisherPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :MEMORANDUM_PUBLISHER)
  end
end
