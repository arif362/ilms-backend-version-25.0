# frozen_string_literal: true

class AlbumPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :ALBUM)
  end
end
