# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Admin
  class DepartmentBiblioItemCreate
    include Interactor

    delegate :goods_receipt, to: :context

    def call
      create_department_biblio_item
    end

    def create_department_biblio_item
      publisher_biblio = goods_receipt.publisher_biblio
      po_line_item = goods_receipt.po_line_item
      quantity = goods_receipt.quantity.to_i
      (1..quantity).each do
        DepartmentBiblioItem.create!(goods_receipt:, publisher_biblio:, po_line_item:)
      end
    end
  end
end
