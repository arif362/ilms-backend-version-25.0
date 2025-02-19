# frozen_string_literal: true

module Admin
  class LmsReports < Admin::Base
    include Admin::Helpers::AuthorizationHelpers

    resources :lms_reports do
      helpers Admin::QueryParams::LmsReportParams

      desc 'Report list'
      params do
        use :pagination, per_page: 25
        optional :year_month, type: String, regexp: /\d{4}-(0[1-9]|1[0-2])/, allow_blank: false
        optional :library_id, type: Integer, allow_blank: false
        optional :library_type, type: String, allow_blank: false, values: %w[division district special upazila branch central]
      end
      get do
        reports = LmsReport.all.where("MONTH(`month`) = ?", DateTime.now.month)

        if params[:year_month].present?
          reports = LmsReport.all
          year, month = params[:year_month].split('-').map(&:to_i)
          error!('Invalid month value.', HTTP_CODE[:BAD_REQUEST]) unless (1..12).include?(month)
          reports = reports.where("MONTH(`month`) = ? AND YEAR(`month`) = ?", month, year)
        end

        if params[:library_type].present?
          reports = LmsReport.joins(:library).where(libraries: { library_type: params[:library_type] })
        end
        reports = Library.find_by(id: params[:library_id])&.lms_reports if params[:library_id].present?
        Admin::Entities::LmsReportList.represent(paginate(reports)) if reports.present?

      end

      route_param :id do
        desc 'library report details'
        get do
          report = LmsReport.find_by(id: params[:id])
          error!('Lms Report not found', HTTP_CODE[:NOT_FOUND]) unless report.present?
          Admin::Entities::LmsReportDetails.represent(report)
        end


        desc 'update lms report'
        params do
          use :lms_report_update_params
        end
        put do
          report = LmsReport.find_by(id: params[:id])
          error!('Lms Report not found', HTTP_CODE[:NOT_FOUND]) unless report.present?

          if params[:papers_bangla].present?
            params[:papers_bangla] = params[:papers_bangla].uniq
            params[:papers_bangla].each do |x|
              paper = Newspaper.where(category: 'daily', language: 'bangla').find_by(id: x)
              next if paper.present?

              error!("papers_bangla id: #{x} doesn\'t exist in ILMS", HTTP_CODE[:NOT_FOUND])
            end
          end

          if params[:papers_english].present?
            params[:papers_english] = params[:papers_english].uniq
            params[:papers_english].each do |x|
              paper = Newspaper.where(category: 'daily', language: 'english').find_by(id: x)
              next if paper.present?

              error!("papers_english id: #{x} doesn\'t exist in ILMS", HTTP_CODE[:NOT_FOUND])
            end
          end


          if params[:magazine_bangla].present?
            params[:magazine_bangla] = params[:magazine_bangla].uniq
            params[:magazine_bangla].each do |x|
              paper = Newspaper.where(category: 'magazine', language: 'bangla').find_by(id: x)
              next if paper.present?

              error!("magazine_bangla id: #{x} doesn\'t exist in ILMS", HTTP_CODE[:NOT_FOUND])
            end
          end
          
          if params[:magazine_english].present?
            params[:magazine_english] = params[:magazine_english].uniq
            params[:magazine_english].each do |x|
              paper = Newspaper.where(category: 'magazine', language: 'english').find_by(id: x)
              next if paper.present?

              error!("magazine_english id: #{x} doesn\'t exist in ILMS", HTTP_CODE[:NOT_FOUND])
            end
          end

          if params[:bind_paper_bangla].present?
            params[:bind_paper_bangla].each do |x|
              paper = Newspaper.find_by(id: x[:newspaper_ref_id])
              next if paper.present?

              error!("bind_paper_bangla id: #{x[:newspaper_ref_id]} doesn\'t exist in ILMS", HTTP_CODE[:NOT_FOUND])
            end
          end

          if params[:bind_paper_english].present?
            params[:bind_paper_english].each do |x|
              paper = Newspaper.find_by(id: x[:newspaper_ref_id])
              next if paper.present?

              error!("bind_paper_english id: #{x[:newspaper_ref_id]} doesn\'t exist in ILMS", HTTP_CODE[:NOT_FOUND])
            end
          end

          if params[:bind_magazine_bangla].present?
            params[:bind_magazine_bangla].each do |x|
              paper = Newspaper.find_by(id: x[:newspaper_ref_id])
              next if paper.present?

              error!("bind_magazine_bangla id: #{x[:newspaper_ref_id]} doesn\'t exist in ILMS", HTTP_CODE[:NOT_FOUND])
            end
          end

          if params[:bind_magazine_english].present?
            params[:bind_magazine_english].each do |x|
              paper = Newspaper.find_by(id: x[:newspaper_ref_id])
              next if paper.present?

              error!("bind_magazine_english id: #{x[:newspaper_ref_id]} doesn\'t exist in ILMS", HTTP_CODE[:NOT_FOUND])
            end
          end

          authorize report, :update?
          report.update!(declared(params).merge!(updated_by: @current_staff))
          Admin::Entities::LmsReportDetails.represent(report)
        end
      end
    end
  end
end
