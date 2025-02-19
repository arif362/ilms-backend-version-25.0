# frozen_string_literal: true

module Lms
  class LmsReports < Lms::Base
    helpers Lms::QueryParams::LmsReportParams
    resources :lms_reports do
      desc 'Report list'
      params do
        use :pagination, per_page: 25
        optional :year_month, type: String, regexp: /\d{4}-(0[1-9]|1[0-2])/
      end
      get do
        reports = @current_library.lms_reports

        if params[:year_month].present?
          year, month = params[:year_month].split('-').map(&:to_i)
          unless (1..12).include?(month)
            error!('Invalid month value.', HTTP_CODE[:BAD_REQUEST])
          end
          reports = reports.where("MONTH(`month`) = ? AND YEAR(`month`) = ?", month, year)
        end

        Lms::Entities::LmsReports.represent(paginate(reports)) if reports.present?

      end

      desc 'Create Lms Report'
      params do
        use :lms_report_create_params
      end
      post do
        staff = @current_library.staffs.find_by(id: params[:staff_id])
        unless staff.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                  @current_library,
                                  false)
          error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
        end
        if params[:papers_bangla].present?
          params[:papers_bangla] = params[:papers_bangla].uniq
          params[:papers_bangla].each do |x|
            paper = Newspaper.where(category: 'daily', language: 'bangla').find_by(id: x)
            next if paper.present?

            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: "papers_bangla id: #{x} doesn\'t exist in ILMS" },
                                    @current_library,
                                    false)
            error!("papers_bangla id: #{x} doesn\'t exist in ILMS", HTTP_CODE[:NOT_FOUND])
          end
        end

        if params[:papers_english].present?
          params[:papers_english] = params[:papers_english].uniq
          params[:papers_english].each do |x|
            paper = Newspaper.where(category: 'daily', language: 'english').find_by(id: x)
            next if paper.present?

            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: "papers_english id: #{x} doesn\'t exist in ILMS" },
                                    @current_library,
                                    false)
            error!("papers_english id: #{x} doesn\'t exist in ILMS", HTTP_CODE[:NOT_FOUND])
          end
        end


        if params[:magazine_bangla].present?
          params[:magazine_bangla] = params[:magazine_bangla].uniq
          params[:magazine_bangla].each do |x|
            paper = Newspaper.where(category: 'magazine', language: 'bangla').find_by(id: x)
            next if paper.present?

            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: "magazine_bangla id: #{x} doesn\'t exist in ILMS" },
                                    @current_library,
                                    false)
            error!("magazine_bangla id: #{x} doesn\'t exist in ILMS", HTTP_CODE[:NOT_FOUND])
          end
        end
        if params[:magazine_english].present?
          params[:magazine_english] = params[:magazine_english].uniq
          params[:magazine_english].each do |x|
            paper = Newspaper.where(category: 'magazine', language: 'english').find_by(id: x)
            next if paper.present?

            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: "magazine_english id: #{x} doesn\'t exist in ILMS" },
                                    @current_library,
                                    false)
            error!("magazine_english id: #{x} doesn\'t exist in ILMS", HTTP_CODE[:NOT_FOUND])
          end
        end

        if params[:bind_paper_bangla].present?
          params[:bind_paper_bangla].each do |x|
            paper = Newspaper.find_by(id: x[:newspaper_ref_id])
            next if paper.present?

            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: "bind_paper_bangla id: #{x[:newspaper_ref_id]} doesn\'t exist in ILMS" },
                                    @current_library,
                                    false)
            error!("bind_paper_bangla id: #{x[:newspaper_ref_id]} doesn\'t exist in ILMS", HTTP_CODE[:NOT_FOUND])
          end
        end

        if params[:bind_paper_english].present?
          params[:bind_paper_english].each do |x|
            paper = Newspaper.find_by(id: x[:newspaper_ref_id])
            next if paper.present?

            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: "bind_paper_english id: #{x[:newspaper_ref_id]} doesn\'t exist in ILMS" },
                                    @current_library,
                                    false)
            error!("bind_paper_english id: #{x[:newspaper_ref_id]} doesn\'t exist in ILMS", HTTP_CODE[:NOT_FOUND])
          end
        end

        if params[:bind_magazine_bangla].present?
          params[:bind_magazine_bangla].each do |x|
            paper = Newspaper.find_by(id: x[:newspaper_ref_id])
            next if paper.present?

            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: "bind_magazine_bangla id: #{x[:newspaper_ref_id]} doesn\'t exist in ILMS" },
                                    @current_library,
                                    false)
            error!("bind_magazine_bangla id: #{x[:newspaper_ref_id]} doesn\'t exist in ILMS", HTTP_CODE[:NOT_FOUND])
          end
        end
        
        if params[:bind_magazine_english].present?
          params[:bind_magazine_english].each do |x|
            paper = Newspaper.find_by(id: x[:newspaper_ref_id])
            next if paper.present?

            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: "bind_magazine_english id: #{x[:newspaper_ref_id]} doesn\'t exist in ILMS" },
                                    @current_library,
                                    false)
            error!("bind_magazine_english id: #{x[:newspaper_ref_id]} doesn\'t exist in ILMS", HTTP_CODE[:NOT_FOUND])
          end
        end

        unless params[:month].day.between?(1, ENV['LMS_REPORT_SUBMIT_LAST_DATE'].to_i)
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:FORBIDDEN],
                                    error: 'Submit reports by the 5th of each month' },
                                  @current_library,
                                  false)
          error!('Submit Reports By The 5th Of Each Month', HTTP_CODE[:FORBIDDEN])

        end

        if @current_library.lms_reports.last.present?
          if @current_library.lms_reports.last&.month&.month == params[:month].month
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:FORBIDDEN],
                                      error: 'Already Submitted This Month Report' },
                                    @current_library,
                                    false)
            error!('Already Submitted This Month Report', HTTP_CODE[:FORBIDDEN])

          end

          unless @current_library.lms_reports.last&.month&.month == params[:month].prev_month.month
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:FORBIDDEN],
                                      error: 'Please, Submit Previous Month Reports' },
                                    @current_library,
                                    false)
            error!('Please, Submit Previous Month Reports', HTTP_CODE[:FORBIDDEN])

          end
        end

        report = @current_library.lms_reports.find_or_create_by!(declared(params, include_missing: false).except(:staff_id).merge!(created_by: staff,
                                                                                                                                   updated_by: staff))
        Lms::Entities::LmsReports.represent(report) if report.present?

      end

      route_param :id do
        desc 'library report details'
        get do
          report = @current_library.lms_reports.find_by(id: params[:id])
          Lms::Entities::LmsReports.represent(report)
        end
      end

    end
  end
end
