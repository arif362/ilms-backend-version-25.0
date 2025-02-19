# frozen_string_literal: true

module Lms
  class Distributions < Lms::Base

    resources :distributions do

      route_param :id do
        # desc 'item receive'
        # params do
        #   use :pagination, per_page: 25
        #   requires :accessions_list, type: Array[String], allow_blank: false
        #   requires :status, type: String, values: %w[received]
        #   requires :staff_id, type: Integer, allow_blank: false
        # end
        #
        # put 'receive#####' do
        #   staff = @current_library.staffs.find_by(id: params[:staff_id])
        #   error!('Staff Not found', HTTP_CODE[:NOT_FOUND]) unless staff.present?
        #
        #   distribution = Distribution.find_by(id: params[:id], library_id: @current_library.id)
        #   error!('Not found', HTTP_CODE[:NOT_FOUND]) unless distribution.present?
        #   error!('Distribution Full Received', HTTP_CODE[:NOT_FOUND]) if distribution.received?
        #
        #   department_biblio_item = distribution.department_biblio_items&.where(central_accession_no: params[:accessions_list])
        #   error!('Department Biblio Item Not found', HTTP_CODE[:NOT_FOUND]) unless department_biblio_item.present?
        #
        #   received_accession = []
        #
        #   department_biblio_item.each do |item|
        #     next unless item.department_biblio_item_status.sent?
        #
        #     if item.update(department_biblio_item_status_id: DepartmentBiblioItemStatus.find_by(status_key: "received").id, updated_by: staff)
        #       received_accession << item.central_accession_no
        #     end
        #   end
        #
        #   error!('No Accession Found', HTTP_CODE[:NOT_FOUND]) unless received_accession.present?
        #
        #   if distribution.department_biblio_items.all? { |item| item.department_biblio_item_status_id == DepartmentBiblioItemStatus.find_by(status_key: "received").id }
        #     distribution.update!(status: 'received')
        #   else
        #     distribution.update!(status: 'partially_received')
        #   end
        #
        #   Lms::Entities::Distributions.represent(distribution, accession_list: received_accession)
        # end

        desc 'item complete receive'
        params do
          use :pagination, per_page: 25
          requires :status, type: String, values: %w[received]
          requires :staff_id, type: Integer, allow_blank: false
        end

        put 'complete' do
          staff = @current_library.staffs.find_by(id: params[:staff_id])
          error!('Staff Not found', HTTP_CODE[:NOT_FOUND]) unless staff.present?

          distribution = Distribution.find_by(id: params[:id], library_id: @current_library.id)
          error!('Not found', HTTP_CODE[:NOT_FOUND]) unless distribution.present?
          error!('Distribution Full Received', HTTP_CODE[:NOT_FOUND]) if distribution.received?
          error!('Distribution Not In Transit', HTTP_CODE[:NOT_FOUND]) unless distribution.in_transit?

          department_biblio_item = distribution.department_biblio_items&.where(department_biblio_item_status_id: DepartmentBiblioItemStatus.find_by(status_key: "sent").id)
          error!('Department Biblio Item Not found', HTTP_CODE[:NOT_FOUND]) unless department_biblio_item.present?

          received_accession = []

          department_biblio_item.each do |item|
            next unless item.department_biblio_item_status.sent?

            if item.update(department_biblio_item_status_id: DepartmentBiblioItemStatus.find_by(status_key: params[:status]).id, updated_by: staff)
              received_accession << item.central_accession_no
            end
          end

          error!('No Accession Found', HTTP_CODE[:NOT_FOUND]) unless received_accession.present?


          if distribution.update!(status: params[:status])
            Lms::Entities::Distributions.represent(distribution, accession_list: received_accession)
          end
        end
      end
    end
  end
end
