# frozen_string_literal: true

module PublicLibrary
  class Events < PublicLibrary::Base
    helpers PublicLibrary::QueryParams::EventRegistrationParams
    resources :events do
      desc 'event list'
      params do
        use :pagination, per_page: 25
        requires :state, type: String, values: %w[upcoming running completed]
        optional :start_date, type: Date
        optional :end_date, type: Date
        optional :count, type: Integer, values: { value: ->(v) { v.positive? }, message: 'must be greater than zero' }
      end
      route_setting :authentication, optional: true
      get do
        events = Event.published.event_state(params[:state])
        if params[:count].present?
          error!('Invalid event state', HTTP_CODE[:NOT_ACCEPTABLE]) unless params[:state] == 'completed'
          events = events.order('RAND()').limit(params[:count])
          PublicLibrary::Entities::Events.represent(events.order(id: :desc),
                                                    locale: @locale,
                                                    request_source: @request_source)
        else
          if params[:state] == 'completed' && params[:start_date].present?
            error!('End date is invalid', HTTP_CODE[:NOT_ACCEPTABLE]) unless params[:end_date].present?
            unless params[:end_date] < Date.today
              error!('End date must be smaller than today', HTTP_CODE[:NOT_ACCEPTABLE])
            end
            error!('End date is invalid', HTTP_CODE[:NOT_ACCEPTABLE]) unless params[:start_date] <= params[:end_date]
            events = events.where('start_date >= ? and end_date <= ?', params[:start_date], params[:end_date])
          end
          PublicLibrary::Entities::Events.represent(paginate(events.order(id: :desc)),
                                                    locale: @locale,
                                                    request_source: @request_source)
        end
      end

      desc 'registered event list'
      params do
        use :pagination, per_page: 25
        optional :start_date, type: Date
        optional :end_date, type: Date
      end
      get 'registered' do
        registered_events = Event.where(id: @current_user.event_registrations.pluck(:event_id).uniq)
        if params[:start_date].blank? && params[:end_date].present?
          error!('Invalid date range', HTTP_CODE[:NOT_ACCEPTABLE])
        end
        if params[:start_date].present?
          unless params[:end_date].present? && params[:start_date] <= params[:end_date]
            error!('Invalid date range', HTTP_CODE[:NOT_ACCEPTABLE])
          end
          registered_events = registered_events.where('DATE(start_date) between ? and ?',
                                                      params[:start_date], params[:end_date])
        end

        PublicLibrary::Entities::RegisterdEventsDetails.represent(paginate(registered_events.order(id: :desc)),
                                                                  locale: @locale,
                                                                  request_source: @request_source, user: @current_user)

      end

      route_param :slug do
        desc 'event libraries'
        params do
          use :pagination, per_page: 25
        end
        route_setting :authentication, optional: true
        get 'event_libraries' do
          event = set_event(params[:slug])
          error!('Event not found', HTTP_CODE[:NOT_FOUND]) unless event.present?
          event_libraries = if !event.is_local
                              Library.all
                            else
                              Library.joins(:event_libraries).where(event_libraries: { event_id: event.id })
                            end
          PublicLibrary::Entities::EventLibraries.represent(event_libraries, locale: @locale)
        end

        desc 'event details'
        params do
          use :pagination, per_page: 25
        end
        route_setting :authentication, optional: true
        get do
          event = set_event(params[:slug])
          error!('Event not found', HTTP_CODE[:NOT_FOUND]) unless event.present?
          PublicLibrary::Entities::EventDetails.represent(event,
                                                          locale: @locale,
                                                          request_source: @request_source,
                                                          current_user: @current_user || nil)
        end

        desc 'user registration to an event'
        params do
          use :event_registration_create_params
        end

        post 'register' do
          event = set_event(params[:slug])
          error!('Event Not Found', HTTP_CODE[:NOT_FOUND]) unless event.present?
          error!('Event Is Not Registrable', HTTP_CODE[:NOT_ACCEPTABLE]) unless event.is_registerable?
          # error!('Event registration expired', HTTP_CODE[:NOT_ACCEPTABLE]) unless event.registration_last_date >= DateTime.now

          # If event is registerable, registration fields must be present
          if params[:registration_fields]&.values&.length&.zero?
            error!('Registration form fields must be present', HTTP_CODE[:NOT_ACCEPTABLE])
          end

          # Check if all required registration fields are present
          params[:registration_fields]&.keys&.each do |key|
            unless Event::REGISTRATION_FIELDS.include?(key)
              error!('Registration form fields must be present', HTTP_CODE[:NOT_ACCEPTABLE])
            end
          end


          library = Library.find_by(code: params[:library_code])
          unless library.present?
            error!("Library not found for the code: #{params[:library_code]}", HTTP_CODE[:NOT_FOUND])
          end


          event_library = if !event.is_local
                            event.event_libraries.find_or_create_by!(library_id: library.id)
                          else
                            event.event_libraries.find_by(library_id: library.id)
                          end

          error!('Library not found for this event', HTTP_CODE[:NOT_FOUND]) unless event_library.present?

          declared_params = {}

          # For each registration field specified in the event, prepare params for registration
          params[:registration_fields]&.keys&.each do |rf|
            error!("#{rf} not found", HTTP_CODE[:NOT_ACCEPTABLE]) unless Event::REGISTRATION_FIELDS.include?(rf)
            declared_params[rf] = params[:registration_fields][rf]
          end

          declared_params.merge!(user_id: @current_user.id, library_id: library.id)

          ActiveRecord::Base.transaction do
            params[:competition_info].each do |competition|
              if EventRegistration.find_by(user_id: @current_user.id, event_id: event.id, competition_name: competition[:competition_name],
                                           library_id: library.id, status: %w[pending approved]).present?
                error!("Already Registered competition_name: #{competition[:competition_name]}", HTTP_CODE[:NOT_ACCEPTABLE])
              end

              event.event_registrations.create!(
                declared_params.merge!(
                  user_id: @current_user.id,
                  competition_name: competition[:competition_name],
                  participate_group: competition[:participate_group],
                  library_id: library.id
                )
              )
            end
          end

          PublicLibrary::Entities::EventRegistrations.represent(event.event_registrations,
                                                                locale: @locale,
                                                                current_user: @current_user)
        end

      end
    end
    helpers do
      def set_event(id_or_slug)
        Event.published.find_by_id(id_or_slug) || Event.published.find_by_slug(id_or_slug)
      end
    end
  end
end
