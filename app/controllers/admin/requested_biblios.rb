# frozen_string_literal: true

module Admin
  class RequestedBiblios < Admin::Base
    include Admin::Helpers::AuthorizationHelpers
    resources :requested_biblios do
      desc 'requested biblios list'
      params do
        use :pagination, per_page: 25
        optional :search_term, type: String
        optional :request_type, type: String, values: %w[library patron]
        optional :start_date, type: Date
        optional :end_date, type: Date
      end
      get do
        requested_biblios = if params[:search_term].present?
                              author = Author.where("lower(CONCAT_WS(' ', first_name, middle_name, last_name)) like ?",
                                                    "%#{params[:search_term].downcase}%").first
                              biblio_subject = BiblioSubject.where('lower(personal_name) like ?',
                                                                   "%#{params[:search_term].downcase}%").first
                              requested_biblios_id = AuthorRequestedBiblio.where(author_id: author&.id).map(&:requested_biblio_id)
                              requested_biblios_id.concat(BiblioSubjectRequestedBiblio.where(biblio_subject_id: biblio_subject&.id).map(&:requested_biblio_id))
                              RequestedBiblio.where('lower(biblio_title) like :search_term or
                                                    lower(isbn) like :search_term or id in (:requested_biblios) or
                                                    lower(authors_name) like :search_term or
                                                    lower(biblio_subjects_name) like :search_term',
                                                    search_term: "%#{params[:search_term].downcase}%",
                                                    requested_biblios: requested_biblios_id.uniq)
                            else
                              RequestedBiblio.all
                            end

        if params[:request_type].present?
          if params[:request_type] == 'library'
            requested_biblios = requested_biblios.where(user_id: nil)
          elsif params[:request_type] == 'patron'
            requested_biblios = requested_biblios.where(library_id: nil)
          end
        end

        if params[:start_date].present? && params[:end_date].blank?
          error!('End date is missing', HTTP_CODE[:NOT_ACCEPTABLE])
        elsif params[:start_date].blank? && params[:end_date].present?
          error!('Start date is missing', HTTP_CODE[:NOT_ACCEPTABLE])
        elsif params[:start_date].present? && params[:end_date].present?
          error!('End date is invalid', HTTP_CODE[:NOT_ACCEPTABLE]) unless params[:end_date] >= params[:start_date]
          requested_biblios = requested_biblios.where('date(created_at) in (?) ',params[:start_date]..params[:end_date])
        end
        authorize requested_biblios, :read?
        Admin::Entities::RequestedBiblios.represent(paginate(requested_biblios.order(id: :desc)))
      end

      route_param :id do
        desc 'requested biblio details'
        get do
          requested_biblio = RequestedBiblio.find_by(id: params[:id])
          error!('Requested biblio not found', HTTP_CODE[:NOT_ACCEPTABLE]) unless requested_biblio.present?
          authorize requested_biblio, :read?
          Admin::Entities::RequestedBiblioDetails.represent(requested_biblio)
        end

        desc 'possible_availability_at'
        params do
          optional :possible_availability_at, type: Date
        end
        patch 'possible_availability_at' do
          requested_biblio = RequestedBiblio.find_by(id: params[:id])
          error!('Requested biblio not found', HTTP_CODE[:NOT_ACCEPTABLE]) unless requested_biblio.present?
          authorize requested_biblio, :update?
          requested_biblio.update!(declared(params))
          Admin::Entities::RequestedBiblioDetails.represent(requested_biblio)
        end
      end
    end
  end
end
