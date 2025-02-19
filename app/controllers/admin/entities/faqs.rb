# frozen_string_literal: true

module Admin
  module Entities
    class Faqs < Grape::Entity

      expose :id
      expose :question
      expose :bn_question
      expose :answer
      expose :bn_answer
      expose :is_published
      expose :position
      expose :faq_category

      def faq_category
        {
          id: object.faq_category_id,
          title: object.faq_category&.title,
          bn_title: object.faq_category&.bn_title
        }
      end
    end
  end
end
