class LibraryPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :LIBRARY)
  end

  def change_password?
    permission?("#{@access_module.to_s.downcase}-change_password")
  end

  def change_ip?
    permission?("#{@access_module.to_s.downcase}-change_ip")
  end
end
