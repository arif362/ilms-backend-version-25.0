# frozen_string_literal: true

module Admin
  module Entities
    class Authors < Grape::Entity
      expose :id
      expose :full_name
      expose :bn_full_name
      expose :title
      expose :dob
      expose :dod
      expose :creator_stuff

      def creator_stuff
        AdminStaffLibrary.creator_stuff(object.created_by_id)
      end
    end
  end
end
