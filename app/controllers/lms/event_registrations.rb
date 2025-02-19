# frozen_string_literal: true

module Lms
  class EventRegistrations < Lms::Base
    resources :event_registrations do
      route_param :id do

        desc 'event registration status update'
        params do
          requires :status, type: String, allow_blank: false, values: (EventRegistration.statuses.keys - ['pending', 'cancel'])
          requires :staff_id, type: Integer, allow_blank: false
          optional :rejection_note, type: String, allow_blank: false
          optional :group, type: String, values: EventRegistration.participate_groups.keys, allow_blank: false
        end

        patch 'status_update' do
          staff = @current_library.staffs.find_by(id: params[:staff_id])
          unless staff.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff not found' },
                                    @current_library, false)
            error!('Staff not found', HTTP_CODE[:NOT_FOUND])
          end
          registared_event = @current_library.event_registrations.find_by(id: params[:id])
          unless registared_event.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Event Registration not found' },
                                    staff, false)
            error!('Registration not found', HTTP_CODE[:NOT_FOUND])
          end
          if registared_event.cancel?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Event Registration not found' },
                                    staff, false)
            error!('Registration not found', HTTP_CODE[:NOT_FOUND])
          end
          unless registared_event.event.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Event Not Found' },
                                    staff, false)
            error!('Event Not Found', HTTP_CODE[:NOT_FOUND])
          end
          unless registared_event.pending?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Event Registration Not In Pending' },
                                    staff, false)
            error!('Event Registration Not In Pending', HTTP_CODE[:NOT_ACCEPTABLE])
          end
          if params[:status] == 'rejected'

          elsif params[:status] == 'rejected'
            unless params[:rejection_note].present?
              LmsLogJob.perform_later(request.headers.merge(params:),
                                      { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'rejection_note Required' },
                                      staff, false)
              error!('rejection_note Required', HTTP_CODE[:NOT_ACCEPTABLE])
            end
          end

          registared_event.update!(declared(params, include_missing: false).except(:staff_id)
                                                                           .merge!(updated_by_id: staff.id))
          Lms::Entities::EventRegistrationStatus.represent(registared_event)
        end



        desc 'event winner'
        params do
          requires :staff_id, type: Integer, allow_blank: false
          requires :winner_position, type: String, allow_blank: false
        end

        patch 'winner' do
          staff = @current_library.staffs.find_by(id: params[:staff_id])
          unless staff.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff not found' },
                                    @current_library, false)
            error!('Staff not found', HTTP_CODE[:NOT_FOUND])
          end
          registared_event = @current_library.event_registrations.find_by(id: params[:id])
          unless registared_event.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Event Registration not found' },
                                    staff, false)
            error!('Registration not found', HTTP_CODE[:NOT_FOUND])
          end
          unless registared_event.event.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Event Not Found' },
                                    staff, false)
            error!('Event Not Found', HTTP_CODE[:NOT_FOUND])
          end
          unless registared_event.approved?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Event Registration Not Approved' },
                                    staff, false)
            error!('Event Registration Not Approved', HTTP_CODE[:NOT_ACCEPTABLE])
          end


          registared_event.update!(is_winner: true, updated_by_id: staff.id, winner_position: params[:winner_position])
          Lms::Entities::EventRegistrationStatus.represent(registared_event)
        end
      end
    end
  end
end
