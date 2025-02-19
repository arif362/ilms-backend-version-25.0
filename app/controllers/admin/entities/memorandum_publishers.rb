# frozen_string_literal: true

module Admin
  module Entities
    class MemorandumPublishers < Grape::Entity

      expose :id
      expose :publisher, using: Admin::Entities::Publishers
      expose :track_no
      expose :is_shortlisted
      expose :is_final_submitted
      expose :submitted_at
    end
  end
end
