# frozen_string_literal: true

module Lms
  class Guests < Lms::Base
    helpers Lms::QueryParams::GuestParams
    resources :guests do
      desc 'Create Guest'
      params do
        use :guest_create_params
      end

      post do
        guest = Guest.new(declared(params).merge(library_id: @current_library.id))
        if guest.save!
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:OK] },
                                  @current_library, true)
          Lms::Entities::Guests.represent(guest)
        end
      end
    end
  end
end
