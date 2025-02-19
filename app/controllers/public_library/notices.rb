# frozen_string_literal: true

module PublicLibrary
  class Notices < PublicLibrary::Base
    resources :notices do
      desc 'Notice List'
      params do
        use :pagination, per_page: 25
        optional :is_latest, type: Boolean, allow_blank: false
        optional :title, type: String
        optional :bn_title, type: String
        optional :start_date, type: DateTime
        optional :end_date, type: DateTime
        optional :count, type: Integer
      end
      route_setting :authentication, optional: true
      get do
        notices = Notice.published.order(published_date: :desc)
        if params[:start_date].present? && params[:end_date].present?
          notices = notices.where(published_date: (params[:start_date].at_beginning_of_day)..(params[:end_date].at_end_of_day))
        end
        notices = notices.where('lower(title) LIKE ?', "%#{params[:title].downcase}%") if params[:title].present?
        if params[:bn_title].present?
          notices = notices.where('lower(bn_title) LIKE ?', "%#{params[:bn_title].downcase}%")
        end

        if params[:is_latest].present? && params[:is_latest] == true
          PublicLibrary::Entities::Notices.represent(notices.limit(3), locale: @locale)
        elsif params[:count].present?
          error!('Count must be greater than zero', HTTP_CODE[:NOT_ACCEPTABLE]) unless params[:count].positive?
          PublicLibrary::Entities::Notices.represent(notices.limit(params[:count]), locale: @locale)
        else
          PublicLibrary::Entities::Notices.represent(paginate(notices), locale: @locale)
        end
      end

      route_param :id do
        desc 'Notice Details'
        route_setting :authentication, optional: true
        get do
          notice = Notice.published.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless notice.present?
          PublicLibrary::Entities::Notices.represent(notice, locale: @locale)
        end
      end
    end
  end
end
