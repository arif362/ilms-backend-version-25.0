# frozen_string_literal: true

module Admin
  class MembershipRequests < Admin::Base
    include Admin::Helpers::AuthorizationHelpers
    # helpers Admin::QueryParams::MembershipParams

    resources :membership_requests do
      desc 'Membership Requests'
      params do
        use :pagination, max_per_page: 25
        optional :status, type: String, values: MembershipRequest.statuses.keys, allow_blank: false
        optional :membership_category, type: String, values: RequestDetail.membership_categories.keys, allow_blank: false
        optional :request_type, type: String, values: MembershipRequest.request_types.keys, allow_blank: false
        optional :library_code, type: String, allow_blank: false
        optional :phone, type: String, allow_blank: false
      end

      get do
        memberships = MembershipRequest.all.order(id: :desc)
        authorize memberships, :read?

        memberships = memberships.where(status: params[:status]) if params[:status].present?
        memberships = memberships.where(request_type: params[:request_type]) if params[:request_type].present?
        if params[:membership_category].present?
          memberships = memberships.joins(:request_detail).where('request_details.membership_category = ?', RequestDetail.membership_categories[params[:membership_category]])
        end

        if params[:phone].present?
          memberships = memberships.joins(:request_detail).where('request_details.phone = ?', params[:phone])
        end
        if params[:library_code].present?
          library = Library.find_by_code(params[:library_code])
          error!('Library Not Found', HTTP_CODE[:NOT_FOUND]) if library.nil?
          memberships = memberships.joins(:request_detail).where('request_details.library_id = ?', library.id)
        end
        Admin::Entities::MembershipRequests.represent(paginate(memberships))
      end

      route_param :id do
        desc 'Membership Requests Details'

        get do
          membership = MembershipRequest.find_by(id: params[:id])
          authorize membership, :read?
          Admin::Entities::RequestDetails.represent(membership.request_detail)
        end
      end
    end
  end
end
