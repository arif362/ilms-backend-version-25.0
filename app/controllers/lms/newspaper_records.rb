# frozen_string_literal: true

module Lms
  class NewspaperRecords < Lms::Base
    resources :newspaper_records do
      helpers Lms::QueryParams::NewspaperRecordParams

      desc 'Newspaper Record list'
      params do
        use :pagination, per_page: 25
      end
      get do
        newspaper_record = LibraryNewspaper.order(id: :desc)
        Lms::Entities::NewspaperRecords.represent(newspaper_record)
      end

      desc 'Newspaper dropdown list'
      get 'newspaper_dropdowns' do
        newspapers = Newspaper.published.order(name: :asc)
        Lms::Entities::NewspaperDropdowns.represent(newspapers)
      end

      desc 'Newspaper record Create'
      params do
        use :newspaper_record_create_params
      end

      post do
        staff = @current_library.staffs.find_by(id: params[:staff_id])
        unless staff.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                  @current_library, false)
          error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
        end

        if params[:is_continue].present? && params[:is_continue] == false && params[:end_date].nil?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:BAD_REQUEST], error: 'end date is required' },
                                  staff, false)
          error!('end date is required', HTTP_CODE[:BAD_REQUEST])
        end
        if params[:end_date].present? && params[:end_date] < params[:start_date]
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:BAD_REQUEST], error: 'end date can\'t be smaller than start date' },
                                  staff, false)
          error!('end date can\'t be smaller than start date', HTTP_CODE[:BAD_REQUEST])
        end

        newspaper = Newspaper.find_by(id: params[:newspaper_id])
        unless newspaper.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'newspaper not found' },
                                  staff, false)
          error!('newspaper not found', HTTP_CODE[:NOT_FOUND])
        end

        library_newspaper = LibraryNewspaper.new(declared(params, include_missing: false).except(:staff_id).merge(
                                                   created_by: staff.id, library_id: @current_library.id
                                                 ))

        if library_newspaper.save
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:OK] },
                                  staff, true)
          Lms::Entities::NewspaperRecords.represent(library_newspaper)
        end
      end

      route_param :id do
        desc 'Newspaper record Details'

        get do
          newspaper = LibraryNewspaper.find_by(id: params[:id])
          error!('newspaper not found') unless newspaper.present?
          Lms::Entities::NewspaperRecords.represent(newspaper)
        end

        desc 'Newspaper record Update'
        params do
          use :newspaper_record_update_params
        end

        put do
          staff = @current_library.staffs.find_by(id: params[:staff_id])
          unless staff.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                    @current_library, false)
            error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
          end
          end_date = params[:end_date]
          # end_date = Date.parse(end_date_string)
          if Date.today.day <= ENV['LMS_REPORT_SUBMIT_LAST_DATE'].to_i
            if end_date.day > ENV['LMS_REPORT_SUBMIT_LAST_DATE'].to_i
              error!("End Date must be less than #{ENV['LMS_REPORT_SUBMIT_LAST_DATE']}", HTTP_CODE[:NOT_ACCEPTABLE])
            end
          elsif Date.today.day >= ENV['LMS_REPORT_SUBMIT_LAST_DATE'].to_i
            if end_date.day < ENV['LMS_REPORT_SUBMIT_LAST_DATE'].to_i
              error!("End Date must be greater than #{ENV['LMS_REPORT_SUBMIT_LAST_DATE']}", HTTP_CODE[:NOT_ACCEPTABLE])
            end
          end

          library_newspaper = LibraryNewspaper.find_by(id: params[:id])

          unless library_newspaper.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'record not found' },
                                    staff, false)
            error!('record not found', HTTP_CODE[:NOT_FOUND])
          end
          if params[:end_date] < library_newspaper.start_date
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'End date can\'t be smaller than Start Date' },
                                    staff, false)
            error!('End date can\'t be smaller than Start Date', HTTP_CODE[:NOT_ACCEPTABLE])
          end

          library_newspaper = LibraryNewspaper.update!(declared(params, include_missing: false)
                                                            .except(:staff_id)
                                                            .merge(updated_by_id: staff.id, library_id: @current_library.id))
          # debugger
          if library_newspaper.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:OK] },
                                    staff, true)
          end
          Lms::Entities::NewspaperRecords.represent(library_newspaper)
        end


        desc 'Newspaper record delete'

        delete do
          newspaper = LibraryNewspaper.find_by(id: params[:id])
          unless newspaper.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'newspaper not found' },
                                    staff, false)
            error!('newspaper not found',HTTP_CODE[:NOT_FOUND])
          end
          newspaper.delete
        end
      end
    end
  end
end
