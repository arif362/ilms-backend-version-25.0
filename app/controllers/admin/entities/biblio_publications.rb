# frozen_string_literal: true

module Admin
  module Entities
    class BiblioPublications < Grape::Entity
      expose :id
      expose :title
      expose :bn_title
      expose :creator_stuff

      def creator_stuff
        AdminStaffLibrary.creator_stuff(object.created_by_id)
      end
    end
  end
end
