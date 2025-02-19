# frozen_string_literal: true

module Lms
  class RebindBiblios < Lms::Base
    helpers Lms::QueryParams::RebindBiblioParams
    resources :rebind_biblios do
      desc 'Create rebind biblio'
      params do
        use :rebind_biblio_create_params
      end

      post do
        staff = @current_library.staffs.library.find_by(id: params[:staff_id])
        unless staff.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                  @current_library, false)
          error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
        end
        biblio_item = @current_library.biblio_items.find_by(id: params[:biblio_item_id])
        unless biblio_item.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Biblio item not found' },
                                  staff, false)
          error!('Biblio item not found', HTTP_CODE[:NOT_FOUND])
        end
        rebind_statuses = RebindBiblio.statuses.keys - ['completed']
        rebind_biblio = @current_library.rebind_biblios.find_by(biblio_item_id: params[:biblio_item_id],
                                                                status: rebind_statuses)
        if rebind_biblio.present?
          Lms::Entities::RebindBiblio.represent(rebind_biblio)
        else
          rebind_biblio = @current_library.rebind_biblios.new(declared(params, include_missing: false)
                                                         .except(:staff_id)
                                                         .merge!(biblio_id: biblio_item.biblio.id,
                                                                 created_by_id: staff.id))
          if rebind_biblio.save!
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:OK] },
                                    staff, true)
            Lms::Entities::RebindBiblio.represent(rebind_biblio)
          end
        end
      end


      desc 'Update status to in_progress of rebind biblio'
      params do
        use :rebind_biblio_update_params
      end

      put 'in_progress' do
        staff = @current_library.staffs.library.find_by(id: params[:staff_id])
        unless staff.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                  @current_library, false)
          error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
        end
        rebind_biblios = []
        params[:accession_numbers].each do |accession_no|
          biblio_item = BiblioItem.find_by(accession_no:, library_id: @current_library.id)
          unless biblio_item.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND],
                                      error: 'Biblio item not found in current library' },
                                    staff, false)
            error!('Biblio item not found in current library', HTTP_CODE[:NOT_FOUND])
          end
          rebind_biblio = biblio_item.rebind_biblios.where(biblio_item_id: biblio_item.id)&.last
          unless rebind_biblio.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Rebind Biblio not found' },
                                    staff, false)
            error!('Rebind Biblio not found', HTTP_CODE[:NOT_FOUND])
          end
          unless rebind_biblio.pending?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:BAD_REQUEST],
                                      error: 'Rebind Biblio not in pending status' },
                                    staff, false)
            error!('Rebind Biblio not in pending status', HTTP_CODE[:BAD_REQUEST])
          end
          rebind_biblios << rebind_biblio
        end

        ActiveRecord::Base.transaction do
          rebind_biblios.each do |rebind_biblio|
            rebind_biblio.update!(status: RebindBiblio.statuses[:in_progress], updated_by_id: staff.id)
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:OK] },
                                    staff, true)
          end
        end
        Lms::Entities::RebindBiblio.represent(rebind_biblios)
      end

      desc 'Update status to completed of rebind biblio'
      params do
        use :rebind_biblio_update_params
      end

      put 'completed' do
        staff = @current_library.staffs.library.find_by(id: params[:staff_id])
        unless staff.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                  @current_library, false)
          error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
        end
        rebind_biblios = []
        params[:accession_numbers].each do |accession_no|
          biblio_item = BiblioItem.find_by(accession_no:, library_id: @current_library.id)
          unless biblio_item.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND],
                                      error: 'Biblio item not found in current library' },
                                    staff, false)
            error!('Biblio item not found in current library', HTTP_CODE[:NOT_FOUND])
          end
          rebind_biblio = biblio_item.rebind_biblios.where(biblio_item_id: biblio_item.id)&.last

          unless rebind_biblio.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Rebind Biblio not found' },
                                    staff, false)
            error!('Rebind Biblio not found', HTTP_CODE[:NOT_FOUND])
          end
          unless rebind_biblio.in_progress?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:BAD_REQUEST],
                                      error: 'Rebind Biblio not in in_progress status' },
                                    staff, false)
            error!('Rebind Biblio not in in_progress status', HTTP_CODE[:BAD_REQUEST])
          end
          rebind_biblios << rebind_biblio
        end

        ActiveRecord::Base.transaction do
          rebind_biblios.each do |rebind_biblio|
            rebind_biblio.update!(status: RebindBiblio.statuses[:completed], updated_by_id: staff.id)
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:OK] },
                                    staff, true)
          end
        end
        Lms::Entities::RebindBiblio.represent(rebind_biblios)
      end
    end
  end
end
