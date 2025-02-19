# frozen_string_literal: true

module Admin
  class NotifyAnnounce < Admin::Base
    include Admin::Helpers::AuthorizationHelpers
    helpers Admin::QueryParams::AnnouncementsParams
    resources :announcements do

      desc 'list all announcement'
      params do
        optional :notification_type, values: Announcement.notification_types.keys
        optional :announcement_for, values: Announcement.announcement_fors.keys
        optional :title
        use :pagination, per_page: 25
      end

      get do
        announcements = Announcement.all
        announcements = Announcement.send(params[:notification_type].to_sym) if params[:notification_type].present?
        announcements = Announcement.send(params[:announcement_for].to_sym) if params[:announcement_for].present?
        if params[:title].present?
          announcements = announcements.where('lower(title) LIKE ?', "%#{params[:title].downcase}%")
        end

        authorize announcements, :read?
        Admin::Entities::Announcements.represent(paginate(announcements.order(id: :desc)))

      end

      desc 'Create Announcement'
      params do
        use :announcement_create_params
      end

      post do

        announcement = Announcement.new(declared(params, include_missing: false))
        authorize announcement, :create?
        announcement.save
        CreateNotificationJob.perform_later(announcement) if announcement.is_published

        Admin::Entities::Announcements.represent(announcement)
      end

      route_param :id do
        desc 'Details of an Announcement'
        get do
          announcement = Announcement.find_by(id: params[:id])
          error!('Announcement Not Found', HTTP_CODE[:NOT_FOUND]) unless announcement.present?
          authorize announcement, :read?
          Admin::Entities::Announcements.represent(announcement)
        end

        desc 'Update an Announcement'
        params do
          use :announcement_update_params
        end
        put do
          announcement = Announcement.find_by(id: params[:id])
          error!('Announcement Not Found', HTTP_CODE[:NOT_FOUND]) unless announcement.present?
          authorize announcement, :update?
          announcement.update!(declared(params, include_missing: false))

          CreateNotificationJob.perform_later(announcement) if announcement.is_published

          Admin::Entities::Announcements.represent(announcement)
        end

        desc 'Delete an Announcement'
        delete do
          announcement = Announcement.find_by(id: params[:id])
          error!('Announcement Not Found', HTTP_CODE[:NOT_FOUND]) unless announcement.present?
          authorize announcement, :delete?
          announcement.destroy!
          {
            message: 'Successfully deleted'
          }
        end
      end
    end
  end
end
