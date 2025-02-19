# frozen_string_literal: true

module PublicLibrary
  class Newspapers < PublicLibrary::Base
    resources :newspapers do

      desc 'Newspaper list for public library'
      params do
        use :pagination, per_page: 25
        requires :newspaper_id, type: Integer, allow_blank: false
        requires :search_date, type: DateTime, allow_blank: false
      end
      route_setting :authentication, optional: true
      get do
        newspaper = Newspaper.find_by(id: params[:newspaper_id])
        error!('Newspaper not found', HTTP_CODE[:NOT_FOUND]) unless newspaper.present?

        library_newspapers = newspaper.library_newspapers
        error!('Library newspaper not found', HTTP_CODE[:NOT_FOUND]) if library_newspapers.nil?

        current_time = DateTime.now

        library_newspapers = library_newspapers.where.not(start_date: nil).where('? BETWEEN start_date AND COALESCE(end_date, ?)', params[:search_date].to_datetime, current_time)

        PublicLibrary::Entities::NewspaperRecords.represent(paginate(library_newspapers.order(id: :desc)), locale: @locale)
      end

      desc 'Newspaper dropdown'
      route_setting :authentication, optional: true
      get 'dropdown' do
        newspapers = Newspaper.includes(:library_newspapers).order(name: :asc)
        PublicLibrary::Entities::Newspapers.represent(newspapers, locale: @locale)
      end

      route_param :id do
        desc 'newspaper record details'

        params do
          use :pagination, per_page: 25
          optional :start_date, type: DateTime
          optional :end_date, type: DateTime
          optional :library_id
        end
        route_setting :authentication, optional: true
        get :records do
          newspaper = Newspaper.find_by(id: params[:id])
          error!('Newspaper not found', HTTP_CODE[:NOT_FOUND]) unless newspaper.present?

          newspaper_records = newspaper.library_newspapers
          if params[:library_id].present?
            library = Library.find_by(id: params[:library_id])
            error!('Library not found', HTTP_CODE[:NOT_FOUND]) unless library.present?
            newspaper_records = newspaper_records.where(library:)
          end

          if params[:start_date].present? && params[:end_date].present?
            start_date = params[:start_date].to_date.beginning_of_day
            end_date = params[:end_date].to_date.end_of_day
            unless start_date <= end_date
              error!('Start date should not greater than end date', HTTP_CODE[:NOT_ACCEPTABLE])
            end
            newspaper_records = newspaper_records.where('end_date >=?', start_date)
            present [] unless newspaper_records.length.positive?
            newspaper_records = newspaper_records.where('start_date <=? OR end_date >=? AND end_date <=? OR start_date <=?', start_date, start_date, end_date, end_date)
          end

          PublicLibrary::Entities::NewspaperRecords.represent(paginate(newspaper_records.order(id: :desc)), locale: @locale)
        end
      end

    end
  end
end
