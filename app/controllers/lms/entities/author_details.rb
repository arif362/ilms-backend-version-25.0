# frozen_string_literal: true

module Lms
  module Entities
    class AuthorDetails < Grape::Entity

      expose :id
      expose :title
      expose :bn_title
      expose :first_name
      expose :bn_first_name
      expose :middle_name
      expose :bn_middle_name
      expose :last_name
      expose :bn_last_name
      expose :dob
      expose :dod
      expose :pob
      expose :created_by_id
      expose :updated_by_id
      expose :deleted_at
      expose :created_at
      expose :updated_at
    end
  end
end
