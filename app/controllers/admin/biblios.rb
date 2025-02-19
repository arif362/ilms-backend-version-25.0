# frozen_string_literal: true

module Admin
  class Biblios < Admin::Base
    resources :biblios do
      include Admin::Helpers::AuthorizationHelpers
      desc 'Biblios List'
      params do
        use :pagination, per_page: 25
        optional :search_term, type: String
        optional :isbn, type: String
        optional :e_book, type: Boolean
      end
      get do
        biblios = params[:e_book].present? ? Biblio.where(is_e_biblio: true) : Biblio.all
        if params[:search_term].present?
          biblios = biblios.where('lower(title) like :search_term or lower(isbn) like :search_term',
                                  search_term: "%#{params[:search_term].downcase}%")
        end
        authorize biblios, :read?
        Admin::Entities::BiblioList.represent(paginate(biblios.order(id: :desc)))
      end

      desc 'Trending Biblios List'
      params do
        use :pagination, per_page: 25
        optional :search_term, type: String
      end
      get 'trending' do
        min_count = ENV['TRENDING_THRESHOLD'].to_i
        biblios = Biblio.where('read_count >= :count and borrow_count >= :count',
                               count: min_count).distinct
        if params[:search_term].present?
          biblios = biblios.where('isbn like :search_term or lower(title) like :search_term',
                                  search_term: "%#{params[:search_term].downcase}%")
        end
        order_expr = Biblio.arel_table[:search_count] + Biblio.arel_table[:borrow_count] + Biblio.arel_table[:read_count]
        biblios = biblios.order(order_expr.desc)
        authorize biblios, :read?
        Admin::Entities::BiblioTrendingList.represent(paginate(biblios))
      end

      desc 'Upcoming Biblios List'
      params do
        use :pagination, per_page: 25
        optional :start_date, type: Date
        optional :end_date, type: Date
        optional :search_term, type: String
      end
      get 'upcoming' do
        biblios = Biblio.left_joins(:biblio_items).where(biblio_items: { id: nil })
        if params[:start_date].present? && params[:end_date].present?
          error!('Invalid date range', HTTP_CODE[:NOT_ACCEPTABLE]) unless params[:start_date] <= params[:end_date]
          biblios = biblios.where('DATE(biblios.created_at) between ? and ?', params[:start_date], params[:end_date])
        end
        if params[:search_term].present?
          biblios = biblios.where('isbn like :search_term or lower(title) like :search_term',
                                  search_term: "%#{params[:search_term].downcase}%")
        end
        authorize biblios, :read?
        Admin::Entities::BiblioUpcomingList.represent(paginate(biblios.order(id: :desc)), type: :upcoming)
      end

      desc 'New Biblios List'
      params do
        use :pagination, per_page: 25
        optional :search_term, type: String
      end
      get 'new' do
        biblios = Biblio.where(is_paper_biblio: true).joins(:biblio_items)
                        .where('DATE(biblio_items.created_at) >= ?', 1.month.ago.to_date).distinct
        if params[:search_term].present?
          biblios = biblios.where('isbn like :search_term or lower(title) like :search_term',
                                  search_term: "%#{params[:search_term].downcase}%")
        end
        authorize biblios, :read?
        Admin::Entities::BiblioUpcomingList.represent(paginate(biblios.order(id: :desc)), type: :new)
      end

      route_param :id do
        desc 'Biblio details'
        params do
          optional :trending, type: Boolean, values: [true]
        end

        get do
          biblio = Biblio.find_by(id: params[:id])
          error!('Biblio not found', HTTP_CODE[:NOT_FOUND]) unless biblio.present?
          authorize biblio, :read?
          if params[:trending] == true
            trending_point = ENV['TRENDING_THRESHOLD'].to_i
            unless biblio.biblio_subjects.present? && biblio.search_count >= trending_point && biblio.borrow_count >= trending_point && biblio.read_count >= trending_point
              error!('Biblio not found in trending list', HTTP_CODE[:NOT_FOUND])
            end
            Admin::Entities::BiblioTrendingDetails.represent(biblio)
          else
            Admin::Entities::BiblioDetails.represent(biblio)
          end
        end

        desc 'Biblio publish_unpublish'
        params do
          requires :is_published, type: Boolean
        end

        patch 'publish_unpublish' do
          biblio = Biblio.find_by(id: params[:id])
          error!('Biblio not found', HTTP_CODE[:NOT_FOUND]) unless biblio.present?
          error!('You already done this action', HTTP_CODE[:CONFLICT]) if biblio.is_published == params[:is_published]
          authorize biblio, :update?
          biblio.update_columns(is_published: params[:is_published])

          status HTTP_CODE[:OK]
          res = {
            title: biblio.title,
            is_published: biblio.is_published,
            updated_at: biblio.updated_at
          }
          present res
        end

        params do
          use :pagination, per_page: 25
          optional :search_term, type: String
        end

        get 'items' do
          biblio = Biblio.find_by(id: params[:id])
          error!('Biblio not found', HTTP_CODE[:NOT_FOUND]) unless biblio.present?
          biblio_items = biblio.biblio_items.order(id: :desc)

          if params[:search_term].present?
            biblio_items = biblios.where('lower(accession_no) like :search_term or lower(central_accession_no) like :search_term',
                                         search_term: "%#{params[:search_term].downcase}%")
          end
          Admin::Entities::BiblioItems.represent(paginate(biblio_items.order(id: :desc)))
        end

      end
    end
  end
end
