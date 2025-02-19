# frozen_string_literal: true

module Admin
  class DepartmentBiblioItems < Admin::Base
    include Admin::Helpers::AuthorizationHelpers
    resources :department_biblio_items do

      desc 'department biblio sent item List'
      params do
        use :pagination, max_per_page: 25
      end
      get 'distributions' do
        department_biblio_items = DepartmentBiblioItem.where.not(department_biblio_item_status_id: nil)

        authorize department_biblio_items, :read?
        Admin::Entities::DepartmentBiblioItemList.represent(paginate(department_biblio_items.order(id: :desc)))
      end

      desc 'Accession assign List'
      params do
        use :pagination, max_per_page: 1000
        optional :central_accession_no, type: String
      end
      get 'accession' do
        department_biblio_items = DepartmentBiblioItem.where.not(central_accession_no: nil)
        if params[:central_accession_no].present?
          department_biblio_items = department_biblio_items.where('lower(central_accession_no) like :search_term',
                                                                     search_term: "%#{params[:search_term].downcase}%")
        end

        authorize department_biblio_items, :read?
        Admin::Entities::DepartmentBiblioItemList.represent(paginate(department_biblio_items.order(id: :desc)))
      end

      desc 'publisher biblio details'
      params do
        requires :publisher_biblio_id, type: Integer, allow_blank: false
      end
      get 'publisher_biblio' do

        publisher_biblios = PublisherBiblio.find_by(id: params[:publisher_biblio_id])

        Admin::Entities::PublisherBiblio.represent(publisher_biblios)
      end

    end
  end
end
