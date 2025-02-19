# frozen_string_literal: true

module Admin
  class Complains < Admin::Base
    resources :complains do
      include Admin::Helpers::AuthorizationHelpers
      helpers Admin::QueryParams::ComplainParams
      desc 'complain List'
      params do
        use :pagination, per_page: 25
        optional :complain_type, type: String, values: %w[book_issue payment_issue library_issue delivery_issue others]
        optional :action_type, type: String, values: %w[open resolved inprogress closed]
      end
      get do
        complains = Complain.not_deleted.all
        complains = complains.where(complain_type: params[:complain_type]) if params[:complain_type].present?
        complains = complains.where(action_type: params[:action_type]) if params[:action_type].present?
        authorize complains, :read?
        Admin::Entities::Complains.represent(paginate(complains.order(id: :desc)))

      rescue Pundit::NotAuthorizedError => e
        Rails.logger.error " NO ACCESS  #{e.message}"
        error!('No access', HTTP_CODE[:FORBIDDEN])
      rescue StandardError => e
        Rails.logger.info("Failed to fetch complains list - #{e.full_message}")
        error!(failure_response('Failed to fetch complains list'))
      end

      route_param :id do
        desc 'complain Details'

        get do
          complain = Complain.not_deleted.find_by(id: params[:id])
          error!('Not found', HTTP_CODE[:NOT_FOUND]) unless complain.present?
          authorize complain, :read?
          Admin::Entities::ComplainDetails.represent(complain)
        rescue Pundit::NotAuthorizedError => e
          Rails.logger.error " NO ACCESS  #{e.message}"
          error!('No access', HTTP_CODE[:FORBIDDEN])
        rescue StandardError => e
          Rails.logger.info("Failed to fetch complain details - #{e.full_message}")
          error!(failure_response('Failed to fetch complain details'))
        end

        desc 'Update complain'
        params do
          optional :action_note, type: String
          requires :action_type, type: String, values: %w[resolved closed]
        end

        put do
          complain = Complain.not_deleted.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless complain.present?
          if complain.action_type == 'resolved' || complain.action_type == 'closed'
            error!("Complaint Is #{complain.action_type}", HTTP_CODE[:NOT_ACCEPTABLE])
          end
          authorize complain, :update?

          complain.update!(declared(params, include_missing: false).except(:send_email,
                                                                           :send_notification).merge!(closed_or_resolved_at: DateTime.now, closed_or_resolved_by_staff_id: @current_staff.id))
          if params[:send_notification]
            Notification.create!(notifiable: complain.user,
                                 notificationable: complain,
                                 message: 'Complain received',
                                 message_bn: 'Complain received')
          end
          Admin::Entities::ComplainDetails.represent(complain)

        rescue Pundit::NotAuthorizedError => e
          Rails.logger.error " NO ACCESS  #{e.message}"
          error!('No access', HTTP_CODE[:FORBIDDEN])

        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.info("Failed to update complain due to -#{e.full_message}")
          error!(e.message.to_s, HTTP_CODE[:BAD_REQUEST])

        rescue StandardError => e
          Rails.logger.info("Failed to update complain due to -#{e.full_message}")
          error!(failure_response('Failed to update complain'))
        end
      end
    end
  end
end
