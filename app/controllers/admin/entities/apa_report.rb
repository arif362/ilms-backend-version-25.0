# frozen_string_literal: true

module Admin
  module Entities
    class ApaReport < Grape::Entity
      expose :id
      expose :month
      expose :library_id
      expose :library_name
      expose :library_type
      expose :reader


      def library_name
        object&.library&.name
      end

      def library_type
        object&.library&.library_type
      end

      def reader
        object["book_reader_#{options[:gender].downcase}".to_sym] + object["paper_magazine_reader_#{options[:gender].downcase}".to_sym]
      end

      def month
        object.month.strftime('%B')
      end

    end
  end
end
