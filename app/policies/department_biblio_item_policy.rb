class DepartmentBiblioItemPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :DEPARTMENT_BIBLIO_ITEM)
  end
end
