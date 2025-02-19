# frozen_string_literal: true

module Admin
  class Notifications < Admin::Base
    resources :notifications do
      desc 'Unread notification count'
      get :count do
        {
          count: @current_staff.notifications.unread.count
        }
      end

      desc 'Notification list'
      params do
        use :pagination, per_page: 25
      end
      get do
        notifications = @current_staff.notifications.order(id: :desc)
        Admin::Entities::AdminNotifications.represent(paginate(notifications))
      end

      desc 'Mark All Notification As Read'
      post :mark_as_read do
        @current_staff.notifications.unread.update_all(is_read: true)
        status HTTP_CODE[:OK]
      end

      route_param :id do
        desc 'Mark the  notification as read'
        put :mark_as_read do
          notification = @current_staff.notifications.unread.find_by(id: params[:id])
          error!('Notification not found', HTTP_CODE[:NOT_FOUND]) unless notification.present?

          Admin::Entities::AdminNotifications.represent(notification) if notification.update!(is_read: true)
        end
      end
    end
  end
end
