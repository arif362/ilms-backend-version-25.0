# frozen_string_literal: true

module PublicLibrary
  module Entities
    class Faqs < Grape::Entity
      expose :question
      expose :answer
      expose :faq_category

      def question
        locale == :en ? object&.question : object&.bn_question
      end

      def answer
        locale == :en ? object&.answer : object&.bn_answer
      end

      def faq_category
        {
          title: locale == :en ? object.faq_category&.title : object.faq_category&.bn_title
        }
      end

      def locale
        options[:locale]
      end
    end
  end
end
