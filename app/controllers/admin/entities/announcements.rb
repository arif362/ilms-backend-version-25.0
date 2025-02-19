# frozen_string_literal: true

module Admin
  module Entities
    class Announcements < Grape::Entity
      expose :id
      expose :title
      expose :bn_title
      expose :description
      expose :bn_description
      expose :notification_type
      expose :announcement_for
    end
  end
end
