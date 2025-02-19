# frozen_string_literal: true

module Admin
  module Entities
    class Albums < Grape::Entity

      expose :id
      expose :title
      expose :bn_title
      expose :album_type
      expose :is_event_album
    end
  end
end
