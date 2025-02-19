# frozen_string_literal: true

module PublicLibrary
  class EventRegistrations < PublicLibrary::Base
    helpers PublicLibrary::QueryParams::EventRegistrationParams
    resources :event_registration do
      route_param :id do

        desc 'event registration status update'

        patch 'cancel' do
          registared_event = EventRegistration.find_by(id: params[:id])
          error!('Event Registration not found', HTTP_CODE[:NOT_ACCEPTABLE]) unless registared_event.present?
          error!('Event Not Found', HTTP_CODE[:NOT_FOUND]) unless registared_event.event.present?
          error!('Not allowed', HTTP_CODE[:NOT_ACCEPTABLE]) unless registared_event.user == @current_user
          error!('Registration can only be canceled when pending.', HTTP_CODE[:FORBIDDEN]) unless registared_event.pending?
          error!('Cancel status not present.', HTTP_CODE[:NOT_ACCEPTABLE]) unless EventRegistration.statuses[:cancel].present?

          registared_event.update!(updated_by_id: @current_user.id, status: EventRegistration.statuses[:cancel])
        end
      end
    end
  end
end
