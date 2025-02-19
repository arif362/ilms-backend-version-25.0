class AnnouncementPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :ANNOUNCEMENT)
  end
end
