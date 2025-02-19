# frozen_string_literal: true

class ApplicationPolicy
  def initialize(current_user, record, access_module)
    @current_user = current_user
    @record = record
    @access_module = access_module
  end

  def read?
    (Role::PERMISSION_GROUP[@access_module][:read] - @current_user&.role&.permission_codes).length < Role::PERMISSION_GROUP[@access_module][:read].length
  end

  def create?
    permission?("#{@access_module.to_s.downcase}-create")
  end

  def update?
    permission?("#{@access_module.to_s.downcase}-update")
  end

  def delete?
    permission?("#{@access_module.to_s.downcase}-delete")
  end

  def type_change?
    permission?("#{@access_module.to_s.downcase}-type_change")
  end

  def permission?(code)
    @current_user&.role&.permission_codes&.include?(code) || false
  end

  def skip?
    true
  end

  class Scope
    attr_reader :current_user, :scope

    def initialize(current_user, scope)
      @current_user = current_user
      @scope = scope
    end
  end
end
