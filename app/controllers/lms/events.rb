# frozen_string_literal: true

module Lms
  class Events < Lms::Base
    resources :events do
      helpers Lms::QueryParams::EventParams
      desc 'event List'
      params do
        use :pagination, per_page: 25
        optional :search_title, type: String
        optional :state, type: String, values: %w[upcoming running completed]
        optional :start_date, type: Date
        optional :end_date, type: Date
        optional :is_published, type: String, values: %w[published unpublished all]
      end
      get do
        events = Event.not_deleted.all
        events = events.event_state(params[:state]) unless params[:state].blank?
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
        unless params[:start_date].blank?
          unless params[:start_date] <= params[:end_date]
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Invalid date range' },
                                    @current_library, false)
            error!('Invalid date range', HTTP_CODE[:NOT_ACCEPTABLE])
          end
          events = events.event_in_date_range(params[:start_date], params[:end_date])
        end
        if params[:search_title].present?
          events = events.where('lower(title) like :search_title or lower(bn_title) like :search_title',
                                search_title: "#{params[:search_title].downcase}%")
        end
        Lms::Entities::Events.represent(paginate(events.order(id: :desc)))
      end

      desc 'Create event'
      params do
        use :event_create_params
      end

      post do
        params_except_images = params.except(:image_file)
        staff = @current_library.staffs.find_by(id: params[:staff_id])
        unless staff.present?
          LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff not found' },
                                  @current_library, false)
          error!('Staff not found', HTTP_CODE[:NOT_FOUND])
        end
        if params[:is_registerable]
          if params[:registration_fields].blank?
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Registration form fields must be present' },
                                    staff, false)
            error!('Registration form fields must be present', HTTP_CODE[:NOT_ACCEPTABLE])
          end
          if params[:registration_last_date].blank?
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Last registration date is missing' },
                                    staff, false)
            error!('Last registration date is missing', HTTP_CODE[:NOT_ACCEPTABLE])
          end
          unless params[:registration_fields].all? { |rf| Event::REGISTRATION_FIELDS.include?(rf) }
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Invalid registration form field' },
                                    staff, false)
            error!('Invalid registration form field', HTTP_CODE[:NOT_ACCEPTABLE])
          end
          if params[:registration_fields].include?('identity_number') && !params[:registration_fields].include?('identity_type')
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Identity type is missing' },
                                    staff, false)
            error!('Identity type is missing', HTTP_CODE[:NOT_ACCEPTABLE])
          end
          if !params[:registration_fields].include?('identity_number') && params[:registration_fields].include?('identity_type')
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Identity number is missing' },
                                    staff, false)
            error!('Identity number is missing', HTTP_CODE[:NOT_ACCEPTABLE])
          end
        else
          params.update(registration_fields: [], registration_last_date: DateTime.now)
        end
        if params[:start_date].to_date == params[:end_date].to_date && params[:start_date].strftime('%H%M%S') >= params[:end_date].strftime('%H%M%S')
          LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                  { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Invalid end time' },
                                  staff, false)
          error!('Invalid end time', HTTP_CODE[:NOT_ACCEPTABLE])
        end
        event = Event.new(declared(params, include_missing: false).except(:staff_id)
                                                                  .merge!(created_by: params[:staff_id],
                                                                          is_local: true))
        ActiveRecord::Base.transaction do
          if event.save!
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:OK]},
                                    @current_library, true)
          end
          if event.event_libraries.create!(library_id: @current_library.id)
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:OK] },
                                    @current_library, true)
          end
        end
        Lms::Entities::EventDetails.represent(event)
      end

      route_param :id do
        desc 'event Details'

        get do
          event = Event.not_deleted.find_by(id: params[:id])
          unless event.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Event not found' },
                                    @current_library, false)
            error!('Event not found', HTTP_CODE[:NOT_FOUND])
          end
          Lms::Entities::EventDetails.represent(event)
        end

        desc 'Update event'
        params do
          use :event_update_params
        end

        put do
          params_except_images = params.except(:image_file)
          staff = @current_library.staffs.find_by(id: params[:staff_id])
          unless staff.present?
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff not found' },
                                    @current_library, false)
            error!('Staff not found', HTTP_CODE[:NOT_FOUND])
          end
          event = @current_library.events.not_deleted.find_by(id: params[:id])
          unless event.present?
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Event not found' },
                                    staff, false)
            error!('Event not found', HTTP_CODE[:NOT_FOUND])
          end
          if params[:start_date].to_date == params[:end_date].to_date && params[:start_date].strftime('%H%M%S') >= params[:end_date].strftime('%H%M%S')
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Invalid end time' },
                                    staff, false)
            error!('Invalid end time', HTTP_CODE[:NOT_ACCEPTABLE])
          end
          if params[:is_registerable]
            if params[:registration_fields].blank?
              LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                      { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Registration form fields must be present' },
                                      staff, false)
              error!('Registration form fields must be present', HTTP_CODE[:NOT_ACCEPTABLE])
            end
            if params[:registration_last_date].blank?
              LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                      { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Last registration date is missing' },
                                      staff, false)
              error!('Last registration date is missing', HTTP_CODE[:NOT_ACCEPTABLE])
            end
            unless params[:registration_fields].all? { |rf| Event::REGISTRATION_FIELDS.include?(rf) }
              LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                      { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Invalid registration form field' },
                                      staff, false)
              error!('Invalid registration form field', HTTP_CODE[:NOT_ACCEPTABLE])
            end
            if params[:registration_fields].include?('identity_number') && !params[:registration_fields].include?('identity_type')
              LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                      { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Identity type is missing' },
                                      staff, false)
              error!('Identity type is missing', HTTP_CODE[:NOT_ACCEPTABLE])
            end
            if !params[:registration_fields].include?('identity_number') && params[:registration_fields].include?('identity_type')
              LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                      { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Identity number is missing' },
                                      staff, false)
              error!('Identity number is missing', HTTP_CODE[:NOT_ACCEPTABLE])
            end
          else
            params.update(registration_fields: [], registration_last_date: DateTime.now)
          end
          if event.update!(declared(params, include_missing: false).except(:staff_id)
                                                                .merge!(updated_by: params[:staff_id]))
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:OK] },
                                    staff, true)
            Lms::Entities::EventDetails.represent(event)
          end
        end

        desc 'event delete'
        params do
          use :event_delete_params
        end
        delete do
          staff = @current_library.staffs.find_by(id: params[:staff_id])
          unless staff.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff not found' },
                                    @current_library, false)
            error!('Staff not found', HTTP_CODE[:NOT_FOUND])
          end
          event = @current_library.events.not_deleted.find_by(id: params[:id])
          unless event.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Event not found' },
                                    staff, false)
            error!('Event not found', HTTP_CODE[:NOT_FOUND])
          end
          unless event.event_registrations.blank?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Has registered user' },
                                    staff, false)
            error!('Has registered user', HTTP_CODE[:NOT_ACCEPTABLE])
          end
          ActiveRecord::Base.transaction do
            if event.update!(is_deleted: true, updated_by: params[:staff_id])
              LmsLogJob.perform_later(request.headers.merge(params:),
                                      { status_code: HTTP_CODE[:OK] },
                                      staff, true)
            end
            if event.event_libraries.delete_all
              LmsLogJob.perform_later(request.headers.merge(params:),
                                      { status_code: HTTP_CODE[:OK] },
                                      staff, true)
            end
          end
          Lms::Entities::EventDetails.represent(event)
        end
      end
    end
  end
end
