module PublicLibrary
  module Entities
    class MembershipRequests < Grape::Entity
      expose :id
      expose :status
      expose :request_type
      expose :member_id
      expose :notes
      expose :user, using: PublicLibrary::Entities::Users
      expose :request_detail, using: PublicLibrary::Entities::RequestDetails
      expose :invoice

      def member_id
        object.member&.id
      end

      def invoice
        object.invoices&.last
      end
    end
  end
end
