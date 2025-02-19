# frozen_string_literal: true

module Admin
  class LostDamagedBiblios < Admin::Base
    def self.search_term
      # code here
    end

    resources :lost_damaged_biblios do

      desc 'List of a lost and damaged_biblios'
      params do
        use :pagination, per_page: 25
        optional :search_term, type: String
        optional :status, type: String, values: LostDamagedBiblio.statuses.keys
        optional :library_code, type: String
        optional :start_date, type: DateTime
        optional :end_date, type: DateTime
      end
      get do
        lost_damaged_biblios = LostDamagedBiblio.joins(:library, biblio_item: :biblio).includes(:library, biblio_item: :biblio)
        if params[:search_term].present?
          lost_damaged_biblios = lost_damaged_biblios.where(
            'lower(biblios.title) like :q OR lower(biblio_items.accession_no) like :q ', q: "%#{params[:search_term].downcase}%"
          )
        end

        lost_damaged_biblios = lost_damaged_biblios.send(params[:status].to_sym) if params[:status].present?

        if params[:library_code].present?
          lost_damaged_biblios = lost_damaged_biblios.where('lower(libraries.code) = ?', params[:library_code].downcase)
        end

        if params[:start_date].present? && params[:end_date].present?
          lost_damaged_biblios = lost_damaged_biblios.where(created_at: (params[:start_date].at_beginning_of_day)..(params[:end_date].at_end_of_day))
        end

        Admin::Entities::LostDamagedBiblios.represent(paginate(lost_damaged_biblios.order(id: :desc)))
      end

      route_param :id do
        desc 'details of a damaged_biblio'
        get do
          lost_damaged_biblio = LostDamagedBiblio.find_by(id: params[:id])
          error!('Biblio Not Found', HTTP_CODE[:NOT_FOUND]) unless lost_damaged_biblio.present?

          Admin::Entities::LostDamagedBiblios.represent(lost_damaged_biblio)
        end
      end
    end
  end
end