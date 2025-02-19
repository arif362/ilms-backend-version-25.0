# frozen_string_literal: true

module Lms
  module Entities
    class RebindBiblio < Grape::Entity
      expose :id
      expose :status
      expose :biblio_item_id
      expose :biblio_id
    end
  end
end
