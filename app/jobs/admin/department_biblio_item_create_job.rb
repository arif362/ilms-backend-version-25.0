# frozen_string_literal: true

module Admin
  class DepartmentBiblioItemCreateJob < ApplicationJob
    queue_as :default

    def perform(goods_receipt)
      Admin::DepartmentBiblioItemCreate.call(goods_receipt:)
    end
  end
end
