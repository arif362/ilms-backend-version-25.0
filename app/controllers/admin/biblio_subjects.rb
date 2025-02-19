# frozen_string_literal: true

module Admin
  class BiblioSubjects < Admin::Base
    resources :biblio_subjects do
      include Admin::Helpers::AuthorizationHelpers
      desc 'biblio subject List'
      params do
        use :pagination, per_page: 25
        optional :search_term, type: String, allow_blank: false
      end
      get do
        biblio_subjects = BiblioSubject.not_deleted.all
        unless params[:search_term].blank?
          biblio_subjects = biblio_subjects.where('lower(personal_name) like ?', "#{params[:search_term].downcase}%")
        end
        authorize biblio_subjects, :read?
        Admin::Entities::BiblioSubjects.represent(paginate(biblio_subjects.order(id: :desc)))
      end

      desc 'biblio subject dropdown list'

      get 'dropdown' do
        biblio_subjects = BiblioSubject.not_deleted
        biblio_subjects = biblio_subjects.order(personal_name: :asc)

        authorize biblio_subjects, :read?

        Admin::Entities::BiblioSubjects.represent(biblio_subjects)
      end

      route_param :id do
        desc 'biblio subject Details'

        get do
          biblio_subject = BiblioSubject.not_deleted.find_by(id: params[:id])
          error!('Not found', HTTP_CODE[:NOT_FOUND]) unless biblio_subject.present?
          authorize biblio_subject, :read?
          Admin::Entities::BiblioSubjectDetails.represent(biblio_subject)
        end
      end
    end
  end
end
