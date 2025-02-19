# frozen_string_literal: true

module Admin
  class RebindBiblios < Admin::Base
    resources :rebind_biblios do
      include Admin::Helpers::AuthorizationHelpers
      desc 'Rebind biblios list'
      params do
        use :pagination, per_page: 25
        optional :library_id, type: String
        optional :start_date, type: Date
        optional :end_date, type: Date
        optional :search_term, type: String
        optional :status, type: String, values: RebindBiblio.statuses.keys
      end

      get do
        rebind_biblios = if params[:status].present?
                           RebindBiblio.send(params[:status])
                         else
                           RebindBiblio.all
                         end
        rebind_biblios = rebind_biblios.where(library_id: params[:library_id]) if params[:library_id].present?
        if params[:start_date].blank? && params[:end_date].present?
          error!('Invalid date range', HTTP_CODE[:NOT_ACCEPTABLE])
        end
        if params[:start_date].present?
          unless params[:end_date].present? && params[:start_date] <= params[:end_date]
            error!('Invalid date range', HTTP_CODE[:NOT_ACCEPTABLE])
          end
          rebind_biblios = rebind_biblios.where('date(rebind_biblios.created_at) in (?)', params[:start_date]..params[:end_date])
        end
        if params[:search_term].present?
          rebind_biblios = rebind_biblios.joins(:biblio, :biblio_item)
                                         .where('lower(title) like :search_term
                                                or lower(accession_no) like :search_term',
                                                search_term: "%#{params[:search_term].downcase}%")
        end
        authorize rebind_biblios, :read?
        Admin::Entities::RebindBiblio.represent(paginate(rebind_biblios.order(id: :desc)))
      end
    end
  end
end
