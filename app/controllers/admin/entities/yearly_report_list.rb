# frozen_string_literal: true

module Admin
  module Entities
    class YearlyReportList < Grape::Entity
      expose :id
      expose :month
      def month
        object.month.strftime('%Y-%m')
      end
    end
  end
end
