# frozen_string_literal: true

module PublicLibrary
  class Notifications < PublicLibrary::Base
    resources :notifications do
      desc 'Unread notification count'
      get :count do
        {
          count: @current_user.notifications.unread.count
        }
      end

      desc 'Notification list'
      params do
        use :pagination, per_page: 25
      end
      get do
        notifications = @current_user.notifications.order(id: :desc)
        PublicLibrary::Entities::Notifications.represent(paginate(notifications), locale: @locale)
      end

      desc 'Mark All Notification As Read'
      post :mark_as_read do
        @current_user.notifications.unread.update_all(is_read: true)
        status HTTP_CODE[:OK]
      end

      route_param :id do
        desc 'Mark the  notification as read'
        put :mark_as_read do
          notification = @current_user.notifications.unread.find_by(id: params[:id])
          error!('Notification not found', HTTP_CODE[:NOT_FOUND]) unless notification.present?

          PublicLibrary::Entities::Notifications.represent(notification) if notification.update!(is_read: true)
        end
      end
    end
  end
end
