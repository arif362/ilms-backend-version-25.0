class BiblioItemTypePolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :BIBLIO_ITEM_TYPE)
  end
end