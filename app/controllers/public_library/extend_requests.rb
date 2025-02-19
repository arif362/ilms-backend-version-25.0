# frozen_string_literal: true

module PublicLibrary
  class ExtendRequests < PublicLibrary::Base
    helpers PublicLibrary::QueryParams::ExtendRequestParams

    resources :extend_requests do
      desc 'Multiple circulation extend request'

      params do
        use :extend_request_create_params
      end

      post do
        extend_requests = []
        circulations = []
        params[:circulation_ids].each do |circulation_id|
          circulation = @current_user.member.circulations.find_by(id: circulation_id)
          error!("Circulation not found with id: #{circulation_id}", HTTP_CODE[:NOT_FOUND]) unless circulation.present?
          unless circulation.circulation_status.borrowed?
            error!("Circulation with id: #{circulation.id} not in borrowed status", HTTP_CODE[:NOT_ACCEPTABLE])
          end
          if circulation.return_order&.present?
            error!("Return already initiated for circulation with id: #{circulation.id}", HTTP_CODE[:NOT_ACCEPTABLE])
          end
          circulations << circulation
        end
        circulations.each do |circulation|
          member_extend_requests = @current_user.member.extend_requests.where(circulation_id: circulation.id)
          if member_extend_requests.present?
            has_pending_or_approved = member_extend_requests.any? do |extend_request|
              extend_request.pending? || extend_request.approved?
            end
            error!('Approved or pending request exist', HTTP_CODE[:NOT_ACCEPTABLE]) if has_pending_or_approved.present?
          end
          extend_requests << circulation.extend_requests.create!(member_id: circulation.member_id,
                                                                 library_id: circulation.library_id,
                                                                 order_id: circulation.order&.id,
                                                                 created_by: @current_user,
                                                                 updated_by: @current_user)
        end
        PublicLibrary::Entities::ExtendRequests.represent(extend_requests,
                                                          locale: @locale,
                                                          request_source: @request_source)
      end
    end
  end
end
