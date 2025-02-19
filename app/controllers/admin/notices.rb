# frozen_string_literal: true

module Admin
  class Notices < Admin::Base
    include Admin::Helpers::AuthorizationHelpers
    helpers Admin::QueryParams::NoticeParams

    resources :notices do
      desc 'Notice List'
      params do
        use :pagination, per_page: 25
        optional :title, type: String
        optional :is_published, type: Boolean
      end

      get do
        notices = Notice.all
        authorize notices, :read?

        notices = notices.where('lower(title) LIKE ?', "%#{params[:title].downcase}%") if params[:title].present?
        notices = notices.where(is_published: params[:is_published]) unless params[:is_published].nil?
        notices = notices.order(id: :desc)
        Admin::Entities::Notices.represent(paginate(notices))
      end

      desc 'Create Notice'
      params do
        use :notice_create_params
      end

      post do
        notice = Notice.new(params)
        authorize notice, :create?
        notice.published_by_id = @current_staff.id if notice.is_published
        notice.created_by_id = @current_staff.id
        notice.save!
        Admin::Entities::NoticeDetails.represent(notice)
      end

      route_param :id do
        desc 'Notice Details'
        get do
          notice = Notice.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless notice.present?
          authorize notice, :read?
          Admin::Entities::NoticeDetails.represent(notice)
        end

        desc 'Notice Update'
        params do
          use :notice_update_params
        end
        put do
          notice = Notice.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless notice.present?
          authorize notice, :update?

          params.merge!(published_by_id: @current_staff.id) if !notice.is_published && params[:is_published]
          notice.update!(params.merge!(updated_by_id: @current_staff.id))
          Admin::Entities::NoticeDetails.represent(notice)
        end

        desc 'Notice Delete'
        delete do
          notice = Notice.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless notice.present?
          authorize notice, :delete?

          notice.update!(is_deleted: true)
        end
      end
    end
  end
end
