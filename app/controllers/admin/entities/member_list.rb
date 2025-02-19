# frozen_string_literal: true

module Admin
  module Entities
    class MemberList < Grape::Entity
      expose :id
      expose :full_name
      expose :unique_id
      expose :phone
      expose :email
      expose :gender
      expose :membership_category
      expose :dob
      expose :mother_name
      expose :father_Name
      expose :library
      expose :pending_invoices_status


      def library
        library = Library.find_by(id: object&.library_id)
        {
          "id": library.id,
          "library_code": library.code
        }
      end

      def full_name
        object&.user&.full_name
      end

      def gender
        object&.user&.gender
      end

      def dob
        object&.user&.dob
      end

      def phone
        object&.user&.phone
      end

      def pending_invoices_status
        reasult = []
        invoices = object&.user&.invoices&.pending

        invoices.each do |x|
          type = if x.invoice_type == "Circulation"
                   "late return"
                 elsif x.invoice_type == "LostDamagedBiblio"
                   x.invoiceable&.status
                 else
                   x.invoice_type
                 end
          reasult << {
            invoice_id: x.id,
            invoice_type: type,
            invoice_status: x.invoice_status,
            invoice_amount: x.invoice_amount
          }
        end
        reasult
      end
    end
  end
end
