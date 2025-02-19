# frozen_string_literal: true

module Admin
  class DeletionRequests < Admin::Base
    resources :account_deletion_requests do
      include Admin::Helpers::AuthorizationHelpers

      desc 'account deletion requests list'
      params do
        use :pagination, per_page: 25
        optional :search_term, type: String
        optional :status, type: String, values: AccountDeletionRequest.statuses.keys
      end
      get do
        deletion_requests = if params[:status].present?
                              AccountDeletionRequest.send("#{params[:status].to_sym}")
                            else
                              AccountDeletionRequest.all
                            end
        if deletion_requests.present? && params[:search_term].present?
          deletion_requests = deletion_requests.joins(:user).where('phone like :search_term or user_id like :search_term',
                                                                   search_term: "#{params[:search_term]}%")
        end
        authorize deletion_requests, :read?
        Admin::Entities::AccountDeletionRequest.represent(paginate(deletion_requests.order(id: :desc)))
      end

      route_param :id do
        desc 'Accept account deletion request'

        put 'accept' do
          deletion_request = AccountDeletionRequest.pending.find_by(id: params[:id])
          error!('Account deletion request not found', HTTP_CODE[:NOT_FOUND]) unless deletion_request.present?
          validate_params = AccountDeletionManagement::ValidateAccountDeletion.call(user: deletion_request.user)
          error!(validate_params.error.to_s, HTTP_CODE[:NOT_ACCEPTABLE]) unless validate_params.success?
          authorize deletion_request, :update?
          deletion_request.update!(status: AccountDeletionRequest.statuses[:accepted], updated_by_id: @current_staff.id)
          deletion_request.update_member_info(@current_staff)
          Admin::Entities::AccountDeletionRequest.represent(deletion_request)
        end

        desc 'account deletion request accept'
        params do
          requires :reason, type: String
        end
        put 'reject' do
          deletion_request = AccountDeletionRequest.pending.find_by(id: params[:id])
          error!('Account deletion request not found', HTTP_CODE[:NOT_FOUND]) unless deletion_request.present?
          authorize deletion_request, :update?
          deletion_request.update!(status: AccountDeletionRequest.statuses[:rejected], updated_by_id: @current_staff.id)
          Admin::Entities::AccountDeletionRequest.represent(deletion_request)
        end
      end
    end
  end
end
