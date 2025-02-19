class EBookPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :E_BOOK)
  end

  def import?
    permission?("#{@access_module.to_s.downcase}-import")
  end

  def delete_all?
    permission?("#{@access_module.to_s.downcase}-delete_all")
  end
end
