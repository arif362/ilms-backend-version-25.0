module Lms
  module Entities
    class MembershipRequests < Grape::Entity
      expose :id
      expose :status
      expose :request_type
      expose :request_detail, using: Admin::Entities::RequestDetails
      expose :invoice

      def invoice
        object.invoices.security_money.last.as_json(only: %i[id invoice_type invoice_status invoice_amount])
      end
    end
  end
end
