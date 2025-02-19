# frozen_string_literal: true

module Lms
  class BiblioSubjects < Lms::Base
    helpers Lms::QueryParams::BiblioSubjectParams
    resources :biblio_subjects do
      desc 'Biblio subject dropdown'

      get 'dropdown' do
        biblio_subjects = BiblioSubject.not_deleted.order(personal_name: :asc)
        Lms::Entities::BiblioSubjectsDropdown.represent(biblio_subjects)
      end

      desc 'Search biblio subject'
      params do
        use :pagination, max_per_page: 25
        requires :search_term, type: String
      end
      get 'search' do
        biblio_subject = BiblioSubject.not_deleted.where('bn_personal_name like :search_term or
                                                          lower(personal_name) like :search_term or
                                                          lower(slug) like :search_term',
                                                         search_term: "%#{params[:search_term].downcase}%")
        Lms::Entities::BiblioSubjectSearch.represent(biblio_subject)
      end

      desc 'Create biblio subject'
      params do
        use :biblio_subject_create_params
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
        biblio_subject = BiblioSubject.not_deleted.find_by('lower(personal_name) like ? or bn_personal_name like ?',
                                                           params[:personal_name].downcase,
                                                           params[:bn_personal_name])

        if biblio_subject.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:CONFLICT], error: 'Biblio subject already exists' },
                                  staff, false)
          status HTTP_CODE[:CONFLICT]
          Lms::Entities::BiblioSubjectDetails.represent(biblio_subject)
        else
          biblio_subject = BiblioSubject.new(declared(params, include_missing: false).except(:staff_id)
                                                                                     .merge!(created_by_id: staff.id))
          if biblio_subject.save!
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:CREATED] },
                                    staff, true)
            Lms::Entities::BiblioSubjectDetails.represent(biblio_subject)
          end
        end
      end

      route_param :id do
        desc 'Update biblio subject'
        params do
          use :biblio_subject_update_params
        end

        put do
          staff = @current_library.staffs.find_by(id: params[:staff_id])
          unless staff.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                    @current_library,
                                    false)
            error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
          end
          biblio_subject = BiblioSubject.not_deleted.find_by(id: params[:id])
          unless biblio_subject.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Biblio subject not found' },
                                    staff, false)
            error!('Biblio subject not found', HTTP_CODE[:NOT_FOUND])
          end
          biblio_subject.update!(declared(params, include_missing: false).except(:staff_id)
                                                                         .merge!(updated_by_id: params[:staff_id]))
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:OK] },
                                  staff, true)
          Lms::Entities::BiblioSubjectDetails.represent(biblio_subject)
        end

        desc 'biblio subject delete'
        params do
          use :biblio_subject_delete_params
        end
        delete do
          staff = @current_library.staffs.find_by(id: params[:staff_id])
          unless staff.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                    @current_library,
                                    false)
            error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
          end
          biblio_subject = BiblioSubject.not_deleted.find_by(id: params[:id])
          unless biblio_subject.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Biblio subject not found' },
                                    staff, false)
            error!('Biblio subject not found', HTTP_CODE[:NOT_FOUND])
          end
          unless biblio_subject.biblio_subject_biblios.blank?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Has associated biblios' },
                                    staff, false)
            error!('Has associated biblios', HTTP_CODE[:NOT_ACCEPTABLE])
          end

          biblio_subject.update!(is_deleted: true, updated_by_id: staff.id, deleted_at: DateTime.now)
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:OK] },
                                  staff, true)
          Lms::Entities::BiblioSubjectDetails.represent(biblio_subject)
        end
      end
    end
  end
end
