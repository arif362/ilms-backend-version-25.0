# frozen_string_literal: true

module Admin
  class Events < Admin::Base
    resources :events do
      include Admin::Helpers::AuthorizationHelpers
      helpers Admin::QueryParams::EventParams

      desc 'event List'
      get 'dropdown' do
        events = Event.not_deleted.all
        authorize events, :read?
        Admin::Entities::EventsDropdown.represent(events.order(title: :asc))
      end

      desc 'event List'
      params do
        use :pagination, per_page: 25
        optional :search_title, type: String
        optional :state, type: String, values: %w[upcoming running completed]
        optional :start_date, type: Date
        optional :end_date, type: Date
        optional :is_published, type: String, values: %w[published unpublished all]
        optional :is_local, type: String, values: %w[local global all]
      end
      get do
        events = if params[:state].present?
                   Event.not_deleted.event_state(params[:state])
                 else
                   Event.not_deleted.all
                 end
        if params[:is_published].present?
          events = case params[:is_published]
                   when 'published'
                     events.where(is_published: true)
                   when 'unpublished'
                     events.where(is_published: false)
                   else
                     events
                   end
        end

        if params[:is_local].present?
          events = case params[:is_local]
                   when 'local'
                     events.where(is_local: true)
                   when 'global'
                     events.where(is_local: false)
                   else
                     events
                   end
        end

        unless params[:start_date].blank?
          error!('Invalid date range', HTTP_CODE[:NOT_ACCEPTABLE]) unless params[:start_date] <= params[:end_date]
          events = events.event_in_date_range(params[:start_date], params[:end_date])
        end
        if params[:search_title].present?
          events = events.where('lower(title) like :search_title or lower(bn_title) like :search_title',
                                search_title: "#{params[:search_title].downcase}%")
        end
        authorize events, :read?
        Admin::Entities::Events.represent(paginate(events.order(id: :desc)))
      end

      desc 'Create event'
      params do
        use :event_create_params
      end

      post do
        if params[:is_registerable]
          if params[:registration_fields].blank?
            error!('Registration form fields must be present', HTTP_CODE[:NOT_ACCEPTABLE])
          end
          if params[:registration_last_date].blank?
            error!('Last registration date is missing', HTTP_CODE[:NOT_ACCEPTABLE])
          end
          unless params[:registration_fields].all? { |rf| Event::REGISTRATION_FIELDS.include?(rf) }
            error!('Invalid registration form field', HTTP_CODE[:NOT_ACCEPTABLE])
          end
          if params[:registration_fields].include?('identity_number') && !params[:registration_fields].include?('identity_type')
            error!('Identity type is missing', HTTP_CODE[:NOT_ACCEPTABLE])
          end
          if !params[:registration_fields].include?('identity_number') && params[:registration_fields].include?('identity_type')
            error!('Identity number is missing', HTTP_CODE[:NOT_ACCEPTABLE])
          end
        else
          params.update(registration_fields: [], registration_last_date: DateTime.now)
        end
        if params[:start_date].to_date == params[:end_date].to_date && params[:start_date].strftime('%H%M%S') >= params[:end_date].strftime('%H%M%S')
          error!('End date cannot be earlier than start date', HTTP_CODE[:NOT_ACCEPTABLE])
        end
        event = Event.new(declared(params, include_missing: false).merge!(created_by: @current_staff.id))
        authorize event, :create?
        Admin::Entities::EventDetails.represent(event) if event.save!
      end

      route_param :id do
        desc 'event Details'

        get do
          event = Event.not_deleted.find_by(id: params[:id])
          error!('Event not found', HTTP_CODE[:NOT_FOUND]) unless event.present?
          authorize event, :read?
          Admin::Entities::EventDetails.represent(event)
        end

        desc 'Update event'
        params do
          use :event_update_params
        end

        put do
          event = Event.not_deleted.find_by(id: params[:id])
          error!('Event not Found', HTTP_CODE[:NOT_FOUND]) unless event.present?
          if params[:start_date].to_date == params[:end_date].to_date && params[:start_date].strftime('%H%M%S') >= params[:end_date].strftime('%H%M%S')
            error!('End date cannot be earlier than start date', HTTP_CODE[:NOT_ACCEPTABLE])
          end
          if params[:is_registerable]
            if params[:registration_fields].blank?
              error!('Registration form fields must be present', HTTP_CODE[:NOT_ACCEPTABLE])
            end
            if params[:registration_last_date].blank?
              error!('Last registration date is missing', HTTP_CODE[:NOT_ACCEPTABLE])
            end
            unless params[:registration_fields].all? { |rf| Event::REGISTRATION_FIELDS.include?(rf) }
              error!('Invalid registration form field', HTTP_CODE[:NOT_ACCEPTABLE])
            end
            if params[:registration_fields].include?('identity_number') && !params[:registration_fields].include?('identity_type')
              error!('Identity type is missing', HTTP_CODE[:NOT_ACCEPTABLE])
            end
            if !params[:registration_fields].include?('identity_number') && params[:registration_fields].include?('identity_type')
              error!('Identity number is missing', HTTP_CODE[:NOT_ACCEPTABLE])
            end
          else
            params.update(registration_fields: [], registration_last_date: DateTime.now)
          end
          authorize event, :update?
          event.update!(params.merge!(updated_by: @current_staff.id))
          Admin::Entities::EventDetails.represent(event)
        end

        desc 'event delete'

        delete do
          event = Event.not_deleted.find_by(id: params[:id])
          error!('Event not found', HTTP_CODE[:NOT_FOUND]) unless event.present?
          error!('Has registered user', HTTP_CODE[:NOT_ACCEPTABLE]) unless event.event_registrations.blank?
          authorize event, :delete?
          event.update!(is_deleted: true, updated_by: @current_staff.id)
          event.event_libraries.delete_all
          Admin::Entities::EventDetails.represent(event)
        end

        desc 'event libraries with registered user'
        get 'event_libraries' do
          event = Event.not_deleted.find_by(id: params[:id])
          error!('Event not found', HTTP_CODE[:NOT_FOUND]) unless event.present?
          event_libraries = event.event_libraries&.where('total_registered > 0')
          authorize event_libraries, :read?
          Admin::Entities::EventLibraries.represent(event_libraries.order(total_registered: :desc))
        end

        desc 'registered users list of the event'
        params do
          use :pagination, per_page: 25
        end
        get 'event_registrations' do
          event = Event.not_deleted.find_by(id: params[:id])
          error!('Event not found', HTTP_CODE[:NOT_FOUND]) unless event.present?
          event_registrations = event.event_registrations
          authorize event_registrations, :read?
          Admin::Entities::EventRegistrations.represent(paginate(event_registrations.order(id: :desc)))
        end
      end
    end
  end
end
