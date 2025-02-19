class MemorandumPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :MEMORANDUM)
  end
end
