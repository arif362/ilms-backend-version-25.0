module Admin
  module Entities
    class MembershipRequests < Grape::Entity
      expose :id
      expose :user, using: Admin::Entities::UserList
      expose :request_detail, using: Admin::Entities::RequestDetails
      expose :status
      expose :request_type
      expose :notes
    end
  end
end
